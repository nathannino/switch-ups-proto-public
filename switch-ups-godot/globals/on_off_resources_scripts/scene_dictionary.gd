extends Resource
class_name scene_dictionary

@export var scenes : Array[scene_dictionary_entry]
var _scene_dictionary : Dictionary

func get_scene_dictionary_entry(key : String)  -> String :
	return _scene_dictionary[key]

func get_scene_dictionary() -> Dictionary :
	return _scene_dictionary

# Makes it easier for me
func populate_scene_dictionary() :
	print("loading scene key/paths")
	for scene in scenes :
		_scene_dictionary[scene.key] = scene.scene
		print("Loaded scene %s" % scene.key)
