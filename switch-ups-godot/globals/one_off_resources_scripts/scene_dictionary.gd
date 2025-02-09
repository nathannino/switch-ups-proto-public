extends Resource
class_name scene_dictionary

@export var scenes : Array[scene_dictionary_entry]
var _scene_dictionary : Dictionary

func get_scene_dictionary_entry(key : String)  -> String :
	return _scene_dictionary[key]

func get_scene_dictionary() -> Dictionary :
	return _scene_dictionary

# Makes it easier for me. We only do this once at the start of the game, so that moving files around without updating the references will fail fast

func populate_scene_dictionary() :
	print("Populating scene dictionary")
	if game_info.dev :
		print("Dev mode enabled : Checking if scenes exists at path. This might take a bit of time")
	for scene in scenes :
		var found = true
		if game_info.dev : # We don't want to waste time checking in the final build, but we don't really care about a hitch at the start of the game in a dev build
			if not ResourceLoader.exists(scene.scene) :
				printerr("Could not find scene \"%s\" at path \"%s\", bailing out asap" % [scene.key, scene.scene])
				Engine.get_main_loop().quit(-1) # Fail fast
				found = false
		_scene_dictionary[scene.key] = scene.scene
		if found : print("Registered scene %s" % scene.key)
