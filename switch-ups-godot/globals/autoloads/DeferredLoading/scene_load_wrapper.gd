extends RefCounted

class_name SceneLoadWrapper

enum LOAD_TARGET {
	PRELOAD,
	PREINIT,
	PREINIT_AWAIT
}

const scene_dict = preload("res://scenes/scene_list.tres")

var path : String
var load_target : LOAD_TARGET
var preload_generations = {}
var await_keys = []
var ready = false
var corrupted = false
var preload_progress = [0]
var node = null
var _preinit_complete = false
var completed_steps = 0
var required_steps = 1
var can_pause = true
var is_game = false

signal preload_complete
signal preinit_complete

static func calculate_required_steps(_preload_generations = {}) -> int :
	return 2 + len(_preload_generations.keys())

static func create() -> SceneLoadWrapper :
	var wrapper = SceneLoadWrapper.new()
	return wrapper

func from_path(_path : String) -> SceneLoadWrapper :
	path = _path
	return self

func as_transition(_key : String) -> SceneLoadWrapper :
	load_target = LOAD_TARGET.PRELOAD
	path = DeferredLoadingManager.transitions[_key]
	if path == null:
		printerr("transition does not exists")
		return null # FIXME : Super bad omg... but since it's only me and gdscript doesn't have exceptions, I want to crash and burn in a way the debugger can help me with
	return self

func from_key(_key : String) -> SceneLoadWrapper :
	if scene_dict.get_scene_dictionary().size() == 0 :
		scene_dict.populate_scene_dictionary()
	var scene = scene_dict.get_scene_dictionary_entry(_key)
	path = scene.scene
	if path == null :
		printerr("Scene does not exists")
		return null # FIXME : Super bad omg... but since it's only me and gdscript doesn't have exceptions, I want to crash and burn in a way the debugger can help me with
	can_pause = scene.can_pause
	return self

func with_preloaded_generations(_preload_generations = {}) -> SceneLoadWrapper :
	preload_generations = _preload_generations
	return self

func with_await_keys(_await_keys = []) -> SceneLoadWrapper :
	await_keys = []
	for _key in _await_keys :
		await_keys.push_back(str(_key))
	return self

func set_can_pause(_bool : bool) -> SceneLoadWrapper :
	can_pause = _bool
	return self

func set_is_game(_bool : bool) -> SceneLoadWrapper :
	is_game = _bool
	return self

func background_preload() -> SceneLoadWrapper :
	load_target = LOAD_TARGET.PRELOAD
	return self

func background_preinit() -> SceneLoadWrapper :
	load_target = LOAD_TARGET.PREINIT
	return self

func background_await() -> SceneLoadWrapper :
	load_target = LOAD_TARGET.PREINIT_AWAIT
	return self

func prepare() -> SceneLoadWrapper :
	if path == null or load_target == null :
		printerr("Yeah no, missing path or load_target in SceneLoadWrapper, bailling out as soon as possible")
		corrupted = true
	required_steps = calculate_required_steps(preload_generations)
	DeferredLoadingManager.prepare_scene(self)
	return self

func start_preload() :
	ResourceLoader.load_threaded_request(path)

func increment_completed_steps() :
	completed_steps += 1

func start_init() :
	if load_target == LOAD_TARGET.PREINIT_AWAIT :
		var loop = true
		while loop :
			loop = false
			for _key in await_keys :
				var _value = DeferredLoadingManager.get_holding_data(_key)
				if _value is Object :
					if _value == DeferredLoadingManager.AWAITING :
						loop = true
			if loop :
				OS.delay_msec(1)
		
	var packed_scene = ResourceLoader.load_threaded_get(path)
	node = packed_scene.instantiate()
	if node.has_method("_deferred_init") :
		node._deferred_init.call_deferred()
	if node.has_signal("preinit_complete") :
		node.preinit_complete.connect(func() : 
			_preinit_complete = true
			increment_completed_steps()
			preinit_complete.emit()
		)
	else :
		_preinit_complete = true
		increment_completed_steps()
		preinit_complete.emit()

func get_finished() :
	assert(ready)
	match load_target :
		LOAD_TARGET.PRELOAD :
			start_init()
			assert(_preinit_complete)
			return node
		LOAD_TARGET.PREINIT, LOAD_TARGET.PREINIT_AWAIT :
			while node == null :
				OS.delay_msec(0.5) # FIXME : BADDDDD
			return node
		_:
			assert(false)
			return null

func get_scene_preload_percent() -> float :
	ResourceLoader.load_threaded_get_status(path,preload_progress)
	return ((completed_steps + preload_progress[0]) / required_steps) * 100

func get_scene_preload_status() -> ResourceLoader.ThreadLoadStatus :
	return ResourceLoader.load_threaded_get_status(path)

func get_preinit_complete() :
	return _preinit_complete
