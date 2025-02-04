extends RefCounted

class_name SceneLoadWrapper

enum LOAD_TARGET {
	PRELOAD,
	PREINIT
}

var path : String
var load_target : LOAD_TARGET
var preload_generations : Dictionary
var ready = false
var corrupted = false
var preload_progress = [0]
var node = null
var _preinit_complete = false
var completed_steps = 0
var required_steps = 1

signal preload_complete
signal preinit_complete

static func calculate_required_steps(_preload_generations = {}) -> int :
	return 3 + len(_preload_generations.keys())

static func preload_scene(_path : String, _preload_generations = {}) -> SceneLoadWrapper :
	var wrapper = SceneLoadWrapper.new()
	wrapper.load_target = LOAD_TARGET.PRELOAD
	wrapper.path = _path
	wrapper.preload_generations = _preload_generations
	wrapper.required_steps = calculate_required_steps(_preload_generations)
	DeferredLoadingManager.prepare_scene(wrapper)
	return wrapper

static func preinit_scene(_path : String, _preload_generations = {}) -> SceneLoadWrapper :
	var wrapper = SceneLoadWrapper.new()
	wrapper.load_target = LOAD_TARGET.PREINIT
	wrapper.path = _path
	wrapper.preload_generations = _preload_generations
	wrapper.required_steps = calculate_required_steps(_preload_generations)
	DeferredLoadingManager.prepare_scene(wrapper)
	return wrapper

func start_preload() :
	ResourceLoader.load_threaded_request(path)

func increment_completed_steps() :
	completed_steps += 1

func start_init() :
	var packed_scene = ResourceLoader.load_threaded_get(path)
	node = packed_scene.instantiate()
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
		LOAD_TARGET.PREINIT :
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
