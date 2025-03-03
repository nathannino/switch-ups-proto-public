extends ms_action_component

class_name ms_ac_ch_energy

@export var energy_change : int

const desc = preload("uid://c50be86xg570j")

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
	var change = battle_log["new_energy"] - spirit.stamina
	spirit.stamina = battle_log["new_energy"]
	if change > 0 :
		battle_root.enter_log_text("TR_BTLLOG_AC_CH_ENERGY_PLUS", {"amount":abs(battle_log["new_energy"])}, {"spirit":SpiritDictionary.spirits[spirit.key].name}, 1)
	elif change < 0 :
		battle_root.enter_log_text("TR_BTLLOG_AC_CH_ENERGY_MINUS", {"amount":abs(battle_log["new_energy"])}, {"spirit":SpiritDictionary.spirits[spirit.key].name}, 1)
	else :
		battle_root.enter_log_text("TR_BTLLOG_AC_CH_ENERGY_NOTHING", {}, {"spirit":SpiritDictionary.spirits[spirit.key].name}, 1)

func already_handled_server(battle_log : Array, position : int) :
	return ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING

func handle_server(turn_calc : Node,user:ms_spirit_active, user_player_node : Node, target : ms_spirit_active, target_player_node : Node, data : Dictionary) -> Array :
	var old_energy = target.current_stamina
	
	target.current_stamina = max(0, target.current_stamina+energy_change)
	
	return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING,[],[user,user_player_node,target,target_player_node],
	{
		"new_energy" : target.current_stamina
	}]
