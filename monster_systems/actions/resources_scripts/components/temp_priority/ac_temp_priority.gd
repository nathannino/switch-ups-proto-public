extends ms_action_component
class_name ms_ac_temp_priority

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
	
	var tr_dict = {"spirit":SpiritDictionary.spirits[spirit.key].name}
	var notr_dict = {"lv":abs(value)}
	var keyadd = "PLUS" if value >= 0 else "MINUS"
	spirit.priority_change += value
	battle_root.enter_log_text("TR_BTLLOG_AC_TEMP_PRIORITY_"+keyadd, notr_dict, tr_dict, 1)
	
	battle_root.pause_battle_log()
	var char = battle_root.get_3d_character(target_info["target_id"])
	char.animation_done.connect(func() :
		battle_root.play_battle_log()
	, CONNECT_ONE_SHOT)
	char.change_stat(ms_constants.index_to_position(target_info["target"]), value)

func already_handled_server(battle_log : Array, position : int) :
	return ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING

func handle_server(turn_calc : Node,user:ms_spirit_active, user_player_node : Node, target : ms_spirit_active, target_player_node : Node, data : Dictionary) -> Array :
	target.priority_change += level_change
	
	return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING,[],[user,user_player_node,target,target_player_node],
	{
		"changed_by" : level_change
	}]
