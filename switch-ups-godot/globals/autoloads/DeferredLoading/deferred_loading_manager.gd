extends Node

var default_scene = "res://scenes/splash/splash.tscn"

enum TRANSITIONS {
	NONE,
	CROSSFADE
}

var holding = {}
var holding_mutex = Mutex.new()
static var AWAITING = Object.new() # Technically not a constant, but used like one, soooooo
var workers = 0
var workers_mutex = Mutex.new() # Jut to be safe...

@onready var loading_circle_anim = $LoadingRoot/LoadingCircleAnchor/LoadingCircle/AnimationPlayer

const CIRCLE_ANIM = "appear"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loading_circle_anim.play(CIRCLE_ANIM)
	current_load_target = null
	$BarAppearTimer.timeout.connect(func() :
		if not current_load_target == null :
			$LoadingRoot/ProgressBar.show_bar()
	)
	change_scene(SceneLoadWrapper.preload_scene(default_scene),true)
	pass # Replace with function body.

var current_load_target : SceneLoadWrapper
var load_blocking = false

var workers_over_zero = false

func _end_thread(thread : Thread) :
	thread.wait_to_finish()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not current_load_target == null :
		_process_load_poll()
	else :
		if not $LoadingRoot/ProgressBar.bar_is_hiding() :
			$LoadingRoot/ProgressBar.hide_bar()
	
	if workers > 0 :
		if not workers_over_zero :
			workers_over_zero = true
			var time = loading_circle_anim.current_animation_position
			loading_circle_anim.stop()
			loading_circle_anim.play(CIRCLE_ANIM)
			loading_circle_anim.seek(time)
	else :
		if workers_over_zero :
			workers_over_zero = false
			var time = loading_circle_anim.current_animation_position
			loading_circle_anim.stop()
			loading_circle_anim.play_backwards(CIRCLE_ANIM)
			loading_circle_anim.seek(time)
	pass

func _process_load_poll() :
	if not $LoadingRoot/ProgressBar.is_showing and $BarAppearTimer.is_stopped() :
		$BarAppearTimer.start()
	$LoadingRoot/ProgressBar.value = current_load_target.get_scene_preload_percent()
	
	if (current_load_target.ready and (not load_blocking or not workers_over_zero)) : #TODO : Add transition support
		var _new_scene = current_load_target.get_finished()
		current_load_target = null
		$ActiveScene.add_child(_new_scene)
		for child in $HoldingScene.get_children() :
			$HoldingScene.remove_child(child)
			child.queue_free()
		$LoadingRoot/ProgressBar.value = 100
	pass

func cancel_scene_load() :
	for child in $HoldingScene.get_children() :
		$HoldingScene.remove_child(child)
		$ActiveScene.add_child(child)
	current_load_target = null
	#TODO : Cancel animations
	pass

func forget(keys: Array[String]) -> void:
	for key in keys :
		pass

func start_deferred_loading(key : String, path : String) -> void:
	pass

func _set_holding_data(key : String, data) -> void:
	holding_mutex.lock()
	holding[key] = data
	holding_mutex.unlock()

func _increment_workers() :
	workers_mutex.lock()
	workers += 1
	workers_mutex.unlock()

func _decrement_workers() :
	workers_mutex.lock()
	workers -= 1
	workers_mutex.unlock()

# Note that making threads is slow on windows, according to the godot documentation. Only use this when deferred loading of data requires a function
func start_deferred_generation(key : String, function : Callable) -> void:
	var thread = Thread.new()
	_set_holding_data(key,AWAITING)
	thread.start(func() : 
		_deferred_generation_thread(key,function)
		thread.wait_to_finish()
	)

func get_holding_data(key : String) :
	return holding.get(key)

func _deferred_generation_thread(key: String, function : Callable) -> void :
	_increment_workers()
	var data = function.call()
	_set_holding_data(key,data)
	_decrement_workers()

func prepare_scene(scene : SceneLoadWrapper) :
	var thread = Thread.new()
	thread.start(func() : preload_scene(scene, thread))

func _end_preload_scene(_scene : SceneLoadWrapper, _thread : Thread) :
	_scene.ready = true
	_decrement_workers()

func preload_scene(_scene : SceneLoadWrapper, _thread : Thread) :
	_increment_workers()
	_scene.ready = false
	for key in _scene.preload_generations :
		_deferred_generation_thread(key,_scene.preload_generations[key])
		_scene.increment_completed_steps()
	_scene.start_preload()
	var preload_complete = false
	while not preload_complete :
		match _scene.get_scene_preload_status() :
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE :
				printerr("Invalid Resource, attempting to recover?")
				if _scene == current_load_target :
					cancel_scene_load()
				_end_preload_scene(_scene,_thread)
				break
			ResourceLoader.THREAD_LOAD_FAILED :
				printerr("Loading failed, bailling out")
				get_tree().quit(-1)
				break
			ResourceLoader.THREAD_LOAD_IN_PROGRESS :
				OS.delay_msec(16)
				break
			ResourceLoader.THREAD_LOAD_LOADED :
				preload_complete = true
				break
	if _scene.load_target >= _scene.LOAD_TARGET.PREINIT :
		var thread = Thread.new() 
		thread.start(func() : 
			_scene.start_init()
			)
		await _scene.preinit_complete
		
		call_deferred("_end_thread",thread)
	_end_preload_scene(_scene,_thread)

func change_scene(scene : SceneLoadWrapper, _load_blocking = false) -> bool :
	if scene.corrupted :
		return false
	#FIXME : handle transitions n stuff
	for child in $ActiveScene.get_children() :
		$ActiveScene.remove_child(child)
		$HoldingScene.add_child(child)
	
	current_load_target = scene
	return true
