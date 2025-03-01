extends ms_action_component
class_name ms_ac_target

@export var target_type : ms_constants.TARGETS
@export var during_turn : bool
@export var action : Array[ms_action_component]

const desc = preload("uid://cvrjfoo54cj7m")
const precommit = preload("uid://cedlvcxxgruty")

func get_desc() -> Node :
	var instance = desc.instantiate()
	instance.component = self
	return instance

func get_child_component(_index : int) -> ms_action_component :
	return action[_index] if _index < action.size() else null

func _select_screen(allow_back : bool) -> Control :
	match target_type :
		ms_constants.TARGETS.SELF_SPIRIT :
			return null
		_:
			var instance = precommit.instantiate()
			instance.target_type = target_type
			instance.allow_back = allow_back
			return instance


func get_precommit() -> Control :
	return _select_screen(true) if not during_turn else null

func serv_requires_interrupt() -> bool :
	return during_turn

func get_interrupt_action() -> Control :
	return _select_screen(false)

func handle_client(battle_log : Dictionary, battle_root : Node) :
	pass # TODO : idk figure it out later

func already_handled_server(battle_log : Array, position : int) :
	return ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_CHILD

func handle_server(user:ms_spirit_active, user_player_node : Node, target : ms_spirit_active, target_player_node : Node, data : Dictionary = {}) -> Array :
	if target_type == ms_constants.TARGETS.SELF_SPIRIT :
		return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_CHILD,[],[user,user_player_node,user,user_player_node],{}]
	
	if data.size() == 0 :
		var request_data = ms_constants.ACTION_COMPONENT_HANDLE_STATE.REQUEST_DATA_CLIENT_REQUIRED if during_turn else ms_constants.ACTION_COMPONENT_HANDLE_STATE.REQUEST_DATA
		return [request_data,[],[user,user_player_node,target,target_player_node],null]
	
	# {"array_pos":_index,"spot_position":ms_constants.index_to_position(_index)}
	
	var new_target_node : Node
	match target_type :
		ms_constants.TARGETS.ALLY_SPIRIT, ms_constants.TARGETS.ALLY_SPOT, ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPIRIT, ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPOT :
			new_target_node = user_player_node
		ms_constants.TARGETS.ENEMY_SPIRIT, ms_constants.TARGETS.ENEMY_SPOT, ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPIRIT, ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPOT :
			new_target_node = target_player_node
	
	var target_team_state = []
	if data["is_precommit"] :
		target_team_state = new_target_node.team
	match target_type :
		ms_constants.TARGETS.ALLY_SPIRIT, ms_constants.TARGETS.ENEMY_SPIRIT, ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPIRIT, ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPIRIT :
			target_team_state = new_target_node.start_turn_team_state
		ms_constants.TARGETS.ALLY_SPOT, ms_constants.TARGETS.ENEMY_SPOT, ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPIRIT, ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPOT, ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPOT :
			target_team_state = new_target_node.team
	
	return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_CHILD,[],
	[user,user_player_node,target_team_state[data["array_pos"]],new_target_node],{}]
