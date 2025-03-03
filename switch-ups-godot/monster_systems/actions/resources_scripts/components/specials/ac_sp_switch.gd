extends ms_action_component
class_name ms_ac_sp_switch

# WARNING : This assumes it will only be used for the switch command (so switching between 2 of the same team)
const precommit = preload("uid://dob82wo6k22hm")

func get_desc() -> Node :
	return null

func get_child_component(_index : int) -> ms_action_component :
	return null

func _select_screen(allow_back : bool) -> Control :
	var instance = precommit.instantiate()
	instance.allow_back = allow_back
	return instance

func get_precommit() -> Control :
	return _select_screen(true)

func serv_requires_interrupt() -> bool :
	return false

func get_interrupt_action() -> Control :
	return _select_screen(false)

func handle_client(battle_log : Dictionary, battle_root : Node) :
	var target_info = battle_log["target_info"]
	battle_root.rotate_visual(battle_log["pid"],battle_log["active"],battle_log["pid"],battle_log["reserve"])
	battle_root.enter_log_text("TR_BTLLOG_AC_SP_SWITCH", {},{"active":SpiritDictionary.spirits[battle_log["active_key"]].name,"reserve":SpiritDictionary.spirits[battle_log["reserve_key"]].name}, 1)
	pass # TODO : idk figure it out later

func already_handled_server(battle_log : Array, position : int) :
	return ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING

func handle_server(turn_calc : Node,user:ms_spirit_active, user_player_node : Node, target : ms_spirit_active, target_player_node : Node, data : Dictionary = {}) -> Array :
	if data.size() == 0 :
		return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.REQUEST_DATA,[],[user,user_player_node,target,target_player_node],null]
	
	var target_team = user_player_node.team
	var target_team_state = user_player_node.start_turn_team_state if data["is_precommit"] else user_player_node.team
	
	# Data = 
	# 	"active" : battle_root.friend_team.find(SceneRoot.team_active_representative),
	# 	"reserve" : battle_root.friend_team.find(SceneRoot.team_reserve_representative),
	
	var active_index =  data["active"]
	var active_spirit = target_team_state[active_index]
	var reserve_index = data["reserve"]
	var reserve_spirit = target_team_state[reserve_index]
	
	target_team[active_index] = reserve_spirit
	target_team[reserve_index] = active_spirit
	
	return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_CHILD,[],
	[user,user_player_node,target,target_player_node],
	{
		"pid":user_player_node.team_id,
		"active":active_index,
		"active_key":active_spirit.key,
		"reserve":reserve_index,
		"reserve_key":reserve_spirit.key}
	]
