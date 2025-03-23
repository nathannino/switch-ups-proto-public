extends ms_action_component
class_name ms_ac_luck

@export var base_chance_percent : float
@export var action : Array[ms_action_component]

const desc = preload("uid://cciubrosm577s")
const placeover_label = preload("uid://bhyel2s4sldmo")

func get_child_component(_index : int) -> ms_action_component :
	return action[_index] if _index < action.size() else null

func get_desc() -> Node :
	var instance = desc.instantiate()
	instance.component = self
	return instance

func get_precommit() -> Control :
	return null

func serv_requires_interrupt() -> bool :
	return false

func get_interrupt_action() -> Control :
	return null

func _delay_battle_log(battle_root : Node) :
	var thread = Thread.new()
	thread.start(func() :
		battle_root.pause_battle_log()
		OS.delay_msec(800)
		battle_root.play_battle_log()
		thread.wait_to_finish.call_deferred()
	)

func _place_label(battle_root : Node,_tr_key,_target,_pos,_offset,_delay,_lifetime) :
	var _label = placeover_label.instantiate()
	_label.text = _tr_key
	_label.start_tween(battle_root, _target,_pos,_offset,_delay,_lifetime)

func handle_client(battle_log : Dictionary, battle_root : Node) :
	# target_info["target_id"],ms_constants.index_to_position(target_info["target"])
	var target_info = battle_log["target_info"]
	const LIFETIME = 1
	
	if battle_log["lucky_status"] :
		battle_root.enter_log_text("TR_BTLLOG_AC_LUCK_LUCKY" if battle_log["luck_result"] else "TR_BTLLOG_AC_LUCK_UNLUCKY", {}, {}, 0.5)
		if battle_log["luck_result"] :
			_place_label(battle_root,"TR_BTLLOG_PLACEOVER_LUCK_LUCKY",target_info["user_id"],ms_constants.index_to_position(target_info["user"]),Vector2.ZERO,0,LIFETIME)
		else :
			_place_label(battle_root,"TR_BTLLOG_PLACEOVER_LUCK_UNLUCKY",target_info["target_id"],ms_constants.index_to_position(target_info["target"]),Vector2.ZERO,0,LIFETIME)
		_delay_battle_log(battle_root)
	elif not battle_log["luck_result"] :
		battle_root.enter_log_text("TR_BTLLOG_AC_LUCK_MISS", {}, {}, 0.5)
		_place_label(battle_root,"TR_BTLLOG_PLACEOVER_LUCK_MISS",target_info["target_id"],ms_constants.index_to_position(target_info["target"]),Vector2.ZERO,0,LIFETIME)
		_delay_battle_log(battle_root)
	
	pass # TODO : idk figure it out later

func already_handled_server(battle_log : Array, position : int) :
	return ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_CHILD if battle_log[position]["luck_result"] else ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING


func handle_server(turn_calc : Node,user:ms_spirit_active, user_player_node : Node, target : ms_spirit_active, target_player_node : Node, data : Dictionary) -> Array :
	var random = 1-ms_constants.calculate_randomness(user,target)
	
	var success = not (random > base_chance_percent)
	
	var lucky_status = (random < base_chance_percent + 0.05 and random > base_chance_percent - 0.05)
	
	return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_CHILD if success else ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING,
	[],
	[user,user_player_node,target,target_player_node],
	{
		"luck_result": success,
		"lucky_status": lucky_status
	}]
