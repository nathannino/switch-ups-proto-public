extends RefCounted

class_name ms_spirit_active

const sp_switch_action = preload("uid://ia42qhobbyee")
const sp_defend_action = preload("uid://bret6c1vixpf5")

var key : String
var key_equip : String
var _current_hp : float = 0
signal current_hp_changed(old : float, new : float)
var current_hp : float:
	get : return _current_hp
	set(value) :
		var old = _current_hp
		_current_hp = value
		current_hp_changed.emit(old,value)
var moves : Array
var extra_move : String
var _current_stamina : int = 0
signal current_stamina_changed(old : int,new : int)
var current_stamina : int :
	get : return _current_stamina
	set(value) :
		var old = _current_stamina
		_current_stamina = value
		current_stamina_changed.emit(old,value)

#region stat_changes
var _atk_concrete_change : int
signal atk_concrete_changed(old,new)
var atk_concrete_change : int :
	get : return _atk_concrete_change
	set(value) :
		var old = _atk_concrete_change
		_atk_concrete_change = value
		atk_concrete_changed.emit(old,value)
const ATK_CONCRETE_CHANGE_MULTI = 20

var _atk_abstract_change : int
signal atk_abstract_changed(old,new)
var atk_abstract_change : int :
	get : return _atk_abstract_change
	set(value) :
		var old = _atk_abstract_change
		_atk_abstract_change = value
		atk_abstract_changed.emit(old,value)
const ATK_ABSTRACT_CHANGE_MULTI = 20

var _defense_change : int
signal defense_changed(old,new)
var defense_change : int :
	get : return _defense_change
	set(value) :
		var old = _defense_change
		_defense_change = value
		defense_changed.emit(old,value)
const DEFENSE_CHANGE_MULTI = 20

var _speed_change : int
signal speed_changed(old,new)
var speed_change : int :
	get : return _speed_change
	set(value) :
		var old = _speed_change
		_speed_change = value
		speed_changed.emit(old,value)
const SPEED_CHANGE_MULTI = 20

var _luck_change : int
signal luck_changed(old,new)
var luck_change : int :
	get : return _luck_change
	set(value) :
		var old = _luck_change
		_luck_change = value
		luck_changed.emit(old,value)
const LUCK_CHANGE_MULTI = 5

var _priority_change : int
signal priority_changed(old,new)
var priority_change : int :
	get : return _luck_change
	set(value) :
		var old = _luck_change
		_luck_change = value
		luck_changed.emit(old,value)
#regionend

var is_defending = false

func read_dict(_data : Dictionary) -> void :
	key = _data["key"]
	key_equip = _data["key_equip"]
	current_hp = _data["hp"]
	moves = _data["actions"]
	extra_move = _data["ex_action"]
	current_stamina = _data["stamina"]
	atk_concrete_change = _data["atk_con"]
	atk_abstract_change = _data["atk_abs"]
	defense_change = _data["def"]
	speed_change = _data["speed"]
	luck_change = _data["luck"]
	priority_change = _data["priority"]

func to_dict() -> Dictionary :
	return {
		"key" = key,
		"key_equip" = key_equip,
		"hp" = current_hp,
		"actions" = moves,
		"ex_action" = extra_move,
		"stamina" = current_stamina,
		"atk_con" = atk_concrete_change,
		"atk_abs" = atk_abstract_change,
		"def" = defense_change,
		"speed" = speed_change,
		"luck" = luck_change,
		"priority" = priority_change,
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

func get_action_index(_action : ms_action) -> int :
	if _action == sp_switch_action :
		return -2
	if _action == sp_defend_action :
		return -1
	# TODO : Defense
	return get_actions_array_converted().find(_action)

func get_action(action_index) -> ms_action :
	if action_index == -2 :
		return sp_switch_action
	elif action_index == -1 or (action_index == moves.size() and key_equip == ""):
		return sp_defend_action
	elif action_index < moves.size() :
		return get_actions_array_converted()[action_index]
	elif action_index == moves.size() :
		return get_extra_action_converted()
	
	printerr("action not found wtf???")
	return null

func get_atk_concrete() :
	return SpiritDictionary.spirits[key].atk_concrete + (atk_concrete_change * ATK_CONCRETE_CHANGE_MULTI)

func get_atk_abstract() :
	return SpiritDictionary.spirits[key].atk_abstract + (atk_abstract_change * ATK_ABSTRACT_CHANGE_MULTI)

func get_defense() :
	return (SpiritDictionary.spirits[key].defense + (defense_change * DEFENSE_CHANGE_MULTI)) * 2 if is_defending else 1

func get_luck() :
	return SpiritDictionary.spirits[key].luck + (luck_change * LUCK_CHANGE_MULTI)

func get_speed() :
	return SpiritDictionary.spirits[key].speed + (speed_change * SPEED_CHANGE_MULTI)\
