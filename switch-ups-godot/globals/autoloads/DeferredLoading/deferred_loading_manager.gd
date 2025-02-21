extends Node

const default_scene = "splash"

@export var animation_root : Node

const transition_array = preload("uid://c14ejtyo4e62")
var transitions : Dictionary

var holding = {}
var holding_mutex = Mutex.new()
static var AWAITING = Object.new() # Technically not a constant, but used like one, soooooo
var workers = 0
var workers_mutex = Mutex.new() # Jut to be safe...

@onready var loading_circle_anim = $LoadingRoot/LoadingCircleAnchor/LoadingCircle/AnimationPlayer

func add_prefix(prefix : String, value) :
	return prefix + "%s" % value

func is_ready(_key : String) -> bool :
	var _data = get_holding_data(_key)
	if _data is Object :
		if _data == AWAITING :
			return false
	return true

const CIRCLE_ANIM = "appear"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loading_circle_anim.play(CIRCLE_ANIM)
	transitions = transition_array.to_dictionary()
	
	current_load_target = null
	$BarAppearTimer.timeout.connect(func() :
		if not current_load_target == null :
			$LoadingRoot/ProgressBar.show_bar()
	)
	change_scene(SceneLoadWrapper.create()
								.background_preload()
								.from_key(default_scene)
								.prepare(),
				SceneLoadWrapper.create()
								.as_transition("fade_to_black")
								.prepare())
	pass # Replace with function body.

var current_load_target : SceneLoadWrapper
var current_load_transition : SceneLoadWrapper
var current_load_scene : Node
var load_midpoint = false
var load_endpoint = false

var workers_over_zero = true

func _end_thread(thread : Thread) :
	thread.wait_to_finish()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not current_load_target == null :
		_process_load_poll()
	else :
		if load_endpoint :
			current_load_scene.end_transition()
			load_endpoint = false
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

var old_load_target
func _process_load_poll() :
	$LoadingRoot/ProgressBar.value = current_load_target.get_scene_preload_percent()
	
	if current_load_transition.ready and current_load_scene == null :
		current_load_scene = current_load_transition.get_finished()
		current_load_scene.reset()
		animation_root.add_child(current_load_scene)
		current_load_scene.active_node = $ActiveScene
		current_load_scene.inactive_node = $HoldingScene

		current_load_scene.animation_midpoint.connect(func () :
			load_midpoint = true
			if not $LoadingRoot/ProgressBar.is_showing and $BarAppearTimer.is_stopped() :
				$BarAppearTimer.start()
			OptionsOverlay.set_can_pause(current_load_target.can_pause)
		,CONNECT_ONE_SHOT)
		current_load_scene.hide_old_scene.connect(func () :
			for child in $HoldingScene.get_children() :
				$HoldingScene.remove_child.call_deferred(child)
				child.queue_free.call_deferred()
		,CONNECT_ONE_SHOT)
		current_load_scene.animation_end.connect(func () :
			current_load_scene.queue_free()
			current_load_scene = null
			current_load_transition = null
			if not old_load_target == null : OptionsOverlay.set_can_pause(old_load_target.can_pause)
			old_load_target = null
			can_change_scene = true
		, CONNECT_ONE_SHOT)
		current_load_scene.start_transition()
		
	
	if current_load_target.ready :
		$LoadingRoot/ProgressBar.value = 100
		
		if load_midpoint :
			var _new_scene = current_load_target.get_finished()
			$ActiveScene.add_child(_new_scene)
			load_endpoint = true
			old_load_target = current_load_target
			current_load_target = null
	pass
	
#TODO : New cancel load scene

func forget(keys: Array[String]) -> void:
	holding_mutex.lock()
	for key in keys :
		holding.erase(key)
		pass
	holding_mutex.unlock()

func start_deferred_loading(key : String, path : String) -> void:
	pass

func _set_holding_data(key : String, data) -> void:
	print("Waiting to add %s to deferred loading database" % key)
	holding_mutex.lock()
	holding[key] = data
	holding_mutex.unlock()
	print("Added %s to deferred loading database" % key)

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
	if scene.corrupted == true :
		printerr("SceneTree reached, bailling out as per previously printerr'ed")
		get_tree().quit(-1)
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
				printerr("Loading invalid Resource, bailing out")
				get_tree().quit(-1)
				break
			ResourceLoader.THREAD_LOAD_FAILED :
				printerr("Loading failed, bailling out")
				get_tree().quit(-1)
				break
			ResourceLoader.THREAD_LOAD_IN_PROGRESS :
				OS.delay_msec(5)
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

var can_change_scene = true
func prevent_change_scene() :
	can_change_scene = false

func change_scene(scene : SceneLoadWrapper, animation : SceneLoadWrapper) -> bool :
	if scene.corrupted :
		printerr("Scene corrupted!")
		return false
	#if not current_load_target == null : #FIXME : Actually make look better than simply overriding
		#printerr("Already switching scenes")
	#FIXME : handle transitions n stuff
	
	if not can_change_scene :
		printerr("change_scene currently prevented. Canceled scene change of : %s" % scene.path)
		return false
	
	for child in $ActiveScene.get_children() :
		$ActiveScene.remove_child(child)
		$HoldingScene.add_child(child)
	
	current_load_target = scene
	if current_load_transition == null :
		current_load_transition = animation
		current_load_scene = null
	load_midpoint = false
	load_endpoint = false
	
	OptionsOverlay.set_can_pause(false)
	
	return true
