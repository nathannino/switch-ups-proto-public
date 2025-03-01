extends ms_action_component
class_name ms_ac_ch_stat_level

@export var stat : ms_constants.STATS
@export var level_change : int

const desc = preload("uid://dw6bamhoodhsd")

func get_desc() -> Node :
	var instance = desc.instantiate()
	instance.component = self
	return instance

func get_child_component(_index : int) -> ms_action_component :
	return null

func get_precommit() -> Control :
	return null

func serv_requires_interrupt() -> bool :
	return false

func get_interrupt_action() -> Control :
	return null

func handle_client(battle_log : Dictionary, battle_root : Node) :
	var target_info = battle_log["target_info"]
	var spirit = battle_root.get_active_spirit(target_info["target_id"],target_info["target"])
	var value = battle_log["changed_by"]
	match battle_log["stat_changed"] :
		ms_constants.STATS.CON_ATK:
			spirit.atk_concrete_change += value
		ms_constants.STATS.ABS_ATK:
			spirit.atk_abstract_change += value
		ms_constants.STATS.DEF:
			spirit.defense_change += value
		ms_constants.STATS.SPEED:
			spirit.speed_change += value
		ms_constants.STATS.LUCK:
			spirit.luck_change += value

func already_handled_server(battle_log : Array, position : int) :
	return ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING

func handle_server(turn_calc : Node,user:ms_spirit_active, user_player_node : Node, target : ms_spirit_active, target_player_node : Node, data : Dictionary) -> Array :
	match stat :
		ms_constants.STATS.CON_ATK:
			target.atk_concrete_change += level_change
		ms_constants.STATS.ABS_ATK:
			target.atk_abstract_change += level_change
		ms_constants.STATS.DEF:
			target.defense_change += level_change
		ms_constants.STATS.SPEED:
			target.speed_change += level_change
		ms_constants.STATS.LUCK:
			target.luck_change += level_change
	
	return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING,[],[user,user_player_node,target,target_player_node],
	{
		"stat_changed" : stat,
		"changed_by" : level_change
	}]
