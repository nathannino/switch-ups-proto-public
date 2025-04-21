extends ms_action_component

class_name ms_ac_ch_active

const desc = preload("uid://nrssduut60jb")

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
	battle_root.rotate_visual(battle_log["old_pid"],battle_log["old_index"],battle_log["new_pid"],battle_log["new_index"])
	battle_root.enter_log_text("TR_BTLLOG_AC_CH_ACTIVE",{},{"spirit1":SpiritDictionary.spirits[battle_log["old_key"]].name,"spirit2":SpiritDictionary.spirits[battle_log["new_key"]].name},1)

func already_handled_server(battle_log : Array, position : int) :
	return ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING

# At this point, we assume that both target and user are from the same player... but just in case it isn't
func handle_server(turn_calc : Node,user:ms_spirit_active, user_player_node : Node, target : ms_spirit_active, target_player_node : Node, data : Dictionary) -> Array :
	var old_index = target_player_node.team.find(target)
	var new_index = user_player_node.team.find(user)
	
	user_player_node.team[new_index] = target
	target_player_node.team[old_index] = user
	
	return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING,
	[] if user_player_node == target_player_node else [ms_constants.ADDITIONNAL_ACTION_COMPONENT_EFFECTS.CLEAR_TARGET_ACTION_DATA],
	[user,user_player_node,target,target_player_node],
	{
		"old_pid" : target_player_node.team_id,
		"old_index" : old_index,
		"old_key" : user.key,
		"new_pid" : user_player_node.team_id,
		"new_index" : new_index,
		"new_key" : target.key,
	}]
