extends RefCounted

class_name ms_spirit_active

var key : String
var key_equip : String
var current_hp : int
var moves : Array
var extra_move : String
var current_stamina : int

func read_dict(_data : Dictionary) -> void :
	key = _data["key"]
	key_equip = _data["key_equip"]
	current_hp = _data["hp"]
	moves = _data["actions"]
	extra_move = _data["ex_action"]
	current_stamina = _data["stamina"]

func to_dict() -> Dictionary :
	return {
		"key" = key,
		"key_equip" = key_equip,
		"hp" = current_hp,
		"actions" = moves,
		"ex_action" = extra_move,
		"stamina" = current_stamina
	}

# We are not sending over a resource omg did you know resource files can have arbitrary code inside? scary.
# Unfortunately, sending over a json requires us to either use an exernal library, or convert to/from a dictionnary ourselves
static func from_dict(_data : Dictionary) -> ms_spirit_active :
	var instance = ms_spirit_active.new()
	instance.read_dict(_data)
	return instance

static func _get_first_three_actions(_spirit : ms_spirit) -> Array :
	var index = 0
	var actions = []
	while (index < _spirit.actions.size() and index < 3) :
		actions.push_back(_spirit.actions[index].key)
		index += 1
	return actions

static func from_spirit(_spirit : ms_spirit) -> ms_spirit_active :
	var instance = ms_spirit_active.new()
	instance.current_hp = _spirit.health
	instance.key = _spirit.key
	instance.moves = _get_first_three_actions(_spirit)
	instance.key_equip = ""
	instance.extra_move = ""
	return instance

func change_equip_key(value : String) :
	if value == "" :
		key_equip = ""
		extra_move = ""
		return
	key_equip = value
	extra_move = SpiritDictionary.spirits[value].actions[0].key

func reset_stats() :
	current_hp = SpiritDictionary.spirits[key].health
	current_stamina = 1

func get_action_converted(_key : String) -> ms_action :
	if _key == extra_move :
		return SpiritDictionary.spirits[key_equip].get_action(_key)
	else :
		return SpiritDictionary.spirits[key].get_action(_key)

func get_actions_array_converted() -> Array[ms_action] :
	var return_value : Array[ms_action]
	for move in moves :
		return_value.push_back(get_action_converted(move))
	return return_value

func get_extra_action_converted() -> ms_action :
	return get_action_converted(extra_move)

func get_actions_combined_converted() -> Array[ms_action] :
	var return_array = get_actions_array_converted()
	if not key_equip == "" :
		return_array.push_back(get_extra_action_converted())
	return return_array
