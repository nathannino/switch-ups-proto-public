extends RefCounted

class_name ms_spirit_active

var key : String
var key_equip : String
var current_hp : int
var moves : Array

func read_dict(_data : Dictionary) -> void :
	key = _data["key"]
	key_equip = _data["key_equip"]
	current_hp = _data["hp"]
	moves = _data["moves"]

func to_dict() -> Dictionary :
	return {
		"key" = key,
		"key_equip" = key_equip,
		"hp" = current_hp,
		"moves" = moves,
	}

# We are not sending over a resource omg did you know resources can have code inside? horrible.
# Unfortunately, sending over a json requires us to either use an exernal library, or convert to/from a dictionnary ourselves
static func from_dict(_data : Dictionary) -> ms_spirit_active :
	var instance = ms_spirit_active.new()
	instance.read_dict(_data)
	return instance

static func from_spirit(_spirit : ms_spirit) -> ms_spirit_active :
	var instance = ms_spirit_active.new()
	instance.current_hp = _spirit.health
	instance.key = _spirit.key
	instance.moves = []
	instance.key_equip = ""
	return instance

func get_moves() -> Array[ms_action] :
	return []
