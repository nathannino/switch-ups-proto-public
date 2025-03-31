extends ms_action_component

class_name ms_ac_heal_target

@export var heal_percent : float

const desc = preload("uid://5rpbx71ta133")
const damage_number = preload("uid://bhyel2s4sldmo")

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

func _delay_battle_log(battle_root : Node, time : int) :
	var thread = Thread.new()
	thread.start(func() :
		battle_root.pause_battle_log()
		OS.delay_msec(time)
		battle_root.play_battle_log()
		thread.wait_to_finish.call_deferred()
	)

func _place_label(battle_root : Node,_leftpad,_dmg,_rightpad,_target,_pos,_offset,_delay,_lifetime) :
	var _label = damage_number.instantiate()
	_label.text = _leftpad + str(_dmg) + _rightpad
	_label.start_tween(battle_root, _target,_pos,_offset,_delay,_lifetime)
	_delay_battle_log(battle_root,int(ceil((_delay + _lifetime)*100)))

func handle_client(battle_log : Dictionary, battle_root : Node) :
	var _offset = Vector2(0,0)
	var _delay = 0
	
	const PLACE_LIFETIME = 1.3
	
	var target_info = battle_log["target_info"]
	var spirit = battle_root.get_active_spirit(target_info["target_id"],target_info["target"])
	spirit.current_hp += battle_log["heal_amount"]
	battle_root.enter_log_text("TR_BTLLOG_AC_HEAL",{"heal":battle_log["heal_amount"]},{"spirit":SpiritDictionary.spirits[spirit.key].name})
	_place_label(battle_root,"[color=#7CB342]",battle_log["heal_amount"],"[/color]",target_info["target_id"],ms_constants.index_to_position(target_info["target"]),_offset,_delay,PLACE_LIFETIME)

func already_handled_server(battle_log : Array, position : int) :
	return ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING

func handle_server(turn_calc : Node,user:ms_spirit_active, user_player_node : Node, target : ms_spirit_active, target_player_node : Node, data : Dictionary) -> Array :
	var _max_health = SpiritDictionary.spirits[target.key].health
	var _heal_amount = _max_health * heal_percent
	_heal_amount = _heal_amount - (max(0,(target.current_hp + _heal_amount)-_max_health))
	
	target.current_hp += _heal_amount
	
	return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING,[],[user,user_player_node,target,target_player_node],
		{
			"heal_amount" = _heal_amount
		}
	]
