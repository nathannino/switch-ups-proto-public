extends ms_action_component
class_name ms_ac_sp_defend

func get_desc() -> Node :
	return null

func get_child_component(_index : int) -> ms_action_component :
	return null

func get_precommit() -> Control :
	return null

func serv_requires_interrupt() -> bool :
	return false

func get_interrupt_action() -> Control :
	return null

func handle_client(battle_log : Dictionary, battle_root : Node) :
	pass

func already_handled_server(battle_log : Array, position : int) :
	return ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING

func handle_server(turn_calc : Node,user:ms_spirit_active, user_player_node : Node, target : ms_spirit_active, target_player_node : Node, data : Dictionary) -> Array :
	user.is_defending = true
	
	return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING,[],[user,user_player_node,target,target_player_node],{}
	]
