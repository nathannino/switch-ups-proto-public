extends Node

var spirits = null

const database_path = "res://monster_systems/spirits/database/"
const DATABASE_LOAD_KEY = "ms_spirit_database"

func _ready() -> void:
	DeferredLoadingManager._deferred_generation_thread(DATABASE_LOAD_KEY,generate_dictionary)
	pass

func generate_dictionary() -> Dictionary :
	var files = DirAccess.get_files_at(database_path)
	var database = {}
	print("Discovering Spirits")
	for file : String in files :
		file = file.replace(".remap","")
		if file.ends_with(".tres") :
			var entry = load(database_path + file)
			database[entry.key] = entry 
			print("Spirit : %s" % entry.key)
	print("search done")
	return database

func _process(_delta: float) -> void:
	if spirits == null :
		var _database = DeferredLoadingManager.get_holding_data(DATABASE_LOAD_KEY)
		if _database is Dictionary :
			spirits = _database
			print("Spirits loaded")
			DeferredLoadingManager.forget([DATABASE_LOAD_KEY])
	pass
