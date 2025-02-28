extends Node

var player_order_data = []
# {
#			"position_to_active" : main_action_menu.spirit_position,
#			"action_index" : current_action_index, # Sending action index to have more freedom regarding forced switches
#			"action_data" : action_data,
#		}
var speed_order = []
var current_handling_order = 0
var battle_log = []
var action_index = []
var target_info = []
var current_data = {}

func get_players() :
	return $"../ServerMain".get_children()

func get_current_action(spirit : ms_spirit_active, action_index : int) :
	return spirit.get_actions_combined_converted()[action_index]

# Rotation not forced by action
func _rotate_to_front_startturn() :
	for index in range(player_order_data.size()) :
		var child = player_order_data[index]
		var target_position = child["position_to_active"]
		if target_position == ms_constants.POSITION.CENTER :
			child["priority_debuff"] = child.get("priority_debuff",0)
		else:
			var node = child["player_node"]
			var old_center = node.team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)]
			var new_center = node.team[ms_constants.position_to_index(target_position)]
			node.team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)] = new_center
			node.team[ms_constants.position_to_index(target_position)]
			child["priority_debuff"] = child.get("priority_debuff",0) - 2
			battle_log.push_back({
				"log_type" : ms_constants.BATTLE_LOG.ROTATE,
				"pid":index,
				"old_index" : ms_constants.position_to_index(target_position),
				"new_index" : ms_constants.position_to_index(ms_constants.POSITION.CENTER),
			})

# We are now at the center
func _determine_move_order() :
	for index in range(player_order_data.size()) :
		var order = player_order_data[index]
		var spirit = order["player_node"].team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)]
		var current_action = get_current_action(spirit,order["action_index"])
		
		var speed = order["priority_debuff"]
		speed += spirit.get_speed() / 1000
		speed += current_action.priority
		
		order["final_speed_stat"] = speed
		order["speedcalc_initial_order"] = index
	
	var temp_orders_speed_sort = player_order_data.duplicate()
	temp_orders_speed_sort.sort_custom(func (a, b) :
		return a["final_speed_stat"] < b["final_speed_stat"]
	)
	
	for dict in temp_orders_speed_sort :
		speed_order.push_back(dict["speedcalc_initial_order"])

func start_turn() :
	speed_order = []
	player_order_data = []
	battle_log = []
	current_handling_order = 0
	action_index = [0]
	current_data = {}
	
	for child in get_players() :
		child.start_turn_team_state = child.team.duplicate()
		child.selected_action_dict["player_node"] = child
		player_order_data.push_back(child.selected_action_dict)
	
	_rotate_to_front_startturn()
	_determine_move_order()
	
	

func get_content_or_wrap(array,index) :
	while index >= array.size() :
		index -= array.size()
	return array[index]

func start_side() :
	var order = player_order_data[speed_order[current_handling_order]]
	var user_node = order["player_node"]
	var enemy_node = player_order_data[get_content_or_wrap(speed_order,current_handling_order+1)]["player_node"]
	var user = user_node.team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)]
	var enemy = enemy_node.team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)]
	target_info = [user,user_node,enemy,enemy_node]

func calculate_next() :
	var order = player_order_data[speed_order[current_handling_order]]
	var action = get_current_action(order["player_node"].team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)],order["action_index"])
	
	var _root_component : ms_action_component = action.get_child_component(action_index[0])
	
	if _root_component == null :
		if current_handling_order >= speed_order.size() :
			$"..".battle_submit_logs_end(battle_log)
			battle_log.clear()
			return
		else :
			current_handling_order += 1
			action_index = [0]
			calculate_next()
			return
	
	var current_component = ms_action_index_manager.get_latest_component(action,action_index)
	if current_component == null :
		ms_action_index_manager.increase_action_index(current_component,action_index)
		calculate_next()
		return
	
	var results = current_component.handle_server(target_info[0],target_info[1],target_info[2],target_info[3],current_data)
	
	var response = results[0]
	if response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.REQUEST_DATA and current_data.size() == 0 :
		if not order["action_data"].size() == 0 :
			current_data = order["action_data"].pop_front()
			ms_action_index_manager.increase_action_index(current_component,action_index)
			calculate_next()
			return
	
	if response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.REQUEST_DATA or response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.REQUEST_DATA_CLIENT_REQUIRED :
		$"..".battle_submit_logs_middle(battle_log)
		battle_log.clear()
		current_data = {}
		return
	
	if response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_CHILD or response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING :
		current_data = {}
		var special_actions = results[1] # FIXME : Do stuff with it
		var result_data = results[3]
		result_data["target_info"] = {
			"user" : target_info[1].team.find(target_info[0]),
			"user_id" : $"../ServerMain".get_children().find(target_info[0]),
			"target" : target_info[3].team.find(target_info[2]),
			"target_id" : $"../ServerMain".get_children().find(target_info[2]),
		}
		result_data["action_index_array"] = action_index
		
		result_data["action_position"] = target_info[0].get_actions_combined_converted().find(action)
		
		target_info = results[2]
		
		battle_log.push_back(result_data)
		
		if response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_CHILD :
			ms_action_index_manager.increase_action_index(current_component,action_index)
		elif response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING :
			ms_action_index_manager.increase_action_index(null,action_index)
		calculate_next()

func send_request_data() :
	var order = player_order_data[speed_order[current_handling_order]]
	var user_node = order["player_node"]
	var action = get_current_action(order["player_node"].team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)],order["action_index"])
	var current_component = ms_action_index_manager.get_latest_component(action,action_index)
	
	user_node.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_REQUEST_DATA).set_content({
		"action_index" : order["action_index"],
		"spirit_index" : target_info[1].team.find(target_info[0]),
		"component_index" : action_index
	}))
