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
var target_info_stack = []
var current_data = {}

func get_players() :
	return $"../ServerMain".get_children()

func get_current_action(spirit : ms_spirit_active, action_index : int) :
	return spirit.get_action(action_index)

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
			node.team[ms_constants.position_to_index(target_position)] = old_center
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
		
		var speed = (order["priority_debuff"]*1000)
		speed += spirit.get_speed()
		speed += current_action.priority * 1000
		
		order["final_speed_stat"] = speed
		order["speedcalc_initial_order"] = index
	
	var temp_orders_speed_sort = player_order_data.duplicate()
	temp_orders_speed_sort.sort_custom(func (a, b) :
		return a["final_speed_stat"] > b["final_speed_stat"]
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
	start_side()
	
	

func get_content_or_wrap(array,index) :
	while index >= array.size() :
		index -= array.size()
	return array[index]

func check_stamina() :
	var order = player_order_data[speed_order[current_handling_order]]
	var user_node = order["player_node"]
	var user = user_node.team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)]
	var action = get_current_action(order["player_node"].team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)],order["action_index"])
	
	var log = {
				"log_type" : ms_constants.BATTLE_LOG.START_ACTION,
				"pid":speed_order[current_handling_order],
				"spirit": ms_constants.position_to_index(ms_constants.POSITION.CENTER),
				"action": order["action_index"],
				"success": false,
			}
	
	
	if (user.current_stamina < action.cost) and (action.cost > 0) :
		log["success"] = false
		battle_log.push_back(log)
		return false
	else :
		log["success"] = true
		user.current_stamina -= action.cost
		battle_log.push_back(log)
		return true

var selected_action
func start_side() :
	var order = player_order_data[speed_order[current_handling_order]]
	var user_node = order["player_node"]
	var enemy_node = player_order_data[get_content_or_wrap(speed_order,current_handling_order+1)]["player_node"]
	var user = user_node.team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)]
	var enemy = enemy_node.team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)]
	target_info_stack = [[user,user_node,enemy,enemy_node]]
	
	selected_action = get_current_action(order["player_node"].team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)],order["action_index"])
	if check_stamina() :
		calculate_next()
	else :
		end_side()

func check_health() -> bool :
	var order = player_order_data[speed_order[current_handling_order]]
	var user_node = order["player_node"]
	var enemy_node = player_order_data[get_content_or_wrap(speed_order,current_handling_order+1)]["player_node"]
	
	return user_node.player_health <= 0 or enemy_node.player_health <= 0

# weh. I have to do both at the same time. This is FIXME : refactor worthy
func increase_action_index_and_set_target(current_component, _current_target) :
	match ms_action_index_manager.increase_action_index(current_component,action_index) :
		ms_action_index_manager.INCREASE_RESULT.STAY :
			pass # We only want to update down
		ms_action_index_manager.INCREASE_RESULT.GO_DOWN :
			target_info_stack.push_back(_current_target)
		ms_action_index_manager.INCREASE_RESULT.GO_UP :
			target_info_stack.pop_back()

func end_side() :
	current_handling_order += 1
	if current_handling_order >= speed_order.size() :
		$"..".battle_submit_logs_end(battle_log)
		battle_log.clear()
		return
	else :
		action_index = [0]
		start_side()
		return

func calculate_next() :
	var order = player_order_data[speed_order[current_handling_order]]
	var user_node = order["player_node"]
	var action = selected_action
	
	var _root_component : ms_action_component = action.get_child_component(action_index[0])
	
	var _target_info = target_info_stack[-1]
	
	if _root_component == null :
		end_side()
		return
	
	var current_component = ms_action_index_manager.get_latest_component(action,action_index)
	if current_component == null :
		increase_action_index_and_set_target(current_component, _target_info)
		ms_action_index_manager.increase_action_index(current_component,action_index)
		calculate_next()
		return
	
	var results = current_component.handle_server(self,_target_info[0],_target_info[1],_target_info[2],_target_info[3],current_data)
	
	var response = results[0]
	if response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.REQUEST_DATA and current_data.size() == 0 :
		if not order["action_data"].size() == 0 :
			current_data = order["action_data"].pop_front()
			calculate_next()
			return
	
	if response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.REQUEST_DATA or response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.REQUEST_DATA_CLIENT_REQUIRED :
		$"..".battle_submit_logs_middle(battle_log)
		battle_log.clear()
		current_data = {}
		return #TODO : Request for more data
	
	if response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_CHILD or response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING :
		current_data = {}
		var special_actions = results[1] # FIXME : Do stuff with it
		
		for _special_action in special_actions :
			match _special_action:
				ms_constants.ADDITIONNAL_ACTION_COMPONENT_EFFECTS.CLEAR_TARGET_ACTION_DATA:
					player_order_data[$"../ServerMain".get_children().find(results[2][3])]["action_data"] = []
					pass
				_:
					pass
		
		var result_data = results[3]
		var new_target_info = results[2]
		result_data["target_info"] = {
			"user" : new_target_info[1].team.find(new_target_info[0]),
			"user_id" : $"../ServerMain".get_children().find(new_target_info[1]),
			"target" : new_target_info[3].team.find(new_target_info[2]),
			"target_id" : $"../ServerMain".get_children().find(new_target_info[3]),
		}
		result_data["action_index_array"] = action_index.duplicate()
		
		result_data["action_position"] = order["action_index"]
		
		battle_log.push_back(result_data)
		
		if response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_CHILD :
			increase_action_index_and_set_target(current_component, new_target_info)
		elif response == ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING :
			action_index[-1] += 1
			#target_info_stack[-1] = target_info # Keeping this as a comment, but we only want to update down.
			#ms_action_index_manager.increase_action_index(null,action_index)
		
		if check_health() :
			$"..".battle_final_submit(battle_log)
			return # We done =D Yippee
		else :
			calculate_next()

#FIXME : This part of the code still isn't tested, because client-side doesn't know how to handle this lol.
func send_request_data() :
	var order = player_order_data[speed_order[current_handling_order]]
	var user_node = order["player_node"]
	var action = get_current_action(order["player_node"].team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)],order["action_index"])
	var current_component = ms_action_index_manager.get_latest_component(action,action_index)
	
	var spirit_index = -1
	var team_index = -1
	var player_nodes = get_players()
	while spirit_index == -1 :
		team_index += 1
		spirit_index =  player_nodes[team_index].team.find(target_info_stack[0][0])
	
	target_info_stack[-1][1].send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_REQUEST_DATA).set_content({
		"action_index" : order["action_index"],
		"team_index" : team_index,
		"spirit_index" : spirit_index,
		"component_index" : action_index
	}))
