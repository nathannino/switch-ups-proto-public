extends RefCounted

class_name SceneLoadWrapper

enum LOAD_TARGET {
	PRELOAD,
	PREINIT
}

const scene_dict = preload("res://scenes/scene_list.tres")

var path : String
var load_target : LOAD_TARGET
var preload_generations = {}
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

static func create() -> SceneLoadWrapper :
	var wrapper = SceneLoadWrapper.new()
	return wrapper

func from_path(_path : String) -> SceneLoadWrapper :
	path = _path
	return self

func from_key(_key : String) -> SceneLoadWrapper :
	if scene_dict.get_scene_dictionary().size() == 0 :
		scene_dict.populate_scene_dictionary()
	path = scene_dict.get_scene_dictionary_entry(_key)
	if path == null :
		printerr("Scene does not exists")
		return null # FIXME : Super bad omg... but since it's only me and gdscript doesn't have exceptions, I want to crash and burn in a way the debugger can help me with
	return self

func with_preloaded_generations(_preload_generations = {}) -> SceneLoadWrapper :
	preload_generations = _preload_generations
	return self

func background_preload() -> SceneLoadWrapper :
	load_target = LOAD_TARGET.PRELOAD
	return self

func background_preinit() -> SceneLoadWrapper :
	load_target = LOAD_TARGET.PREINIT
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
