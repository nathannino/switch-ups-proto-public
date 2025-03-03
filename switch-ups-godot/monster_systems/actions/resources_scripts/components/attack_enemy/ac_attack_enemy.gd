extends ms_action_component

class_name ms_ac_attack_enemy

@export var base_atk : int
@export var atk_flavor : ms_constants.ATK_FLAVOR

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
	spirit.current_hp -= battle_log["spirit_damage"]
	if battle_log["spirit_damage"] > 0 :
		battle_root.enter_log_text("TR_BTLLOG_AC_ATTACK",{"dmg":battle_log["spirit_damage"]},{"spirit":SpiritDictionary.spirits[spirit.key].name})
	var player_dmg = battle_log["overflow_damage"]
	if player_dmg > 0 :
		battle_root.change_player_hp(target_info["target_id"],-player_dmg)
		battle_root.enter_log_text("TR_BTLLOG_AC_ATTACK_OVERFLOW",{"dmg":player_dmg})

func already_handled_server(battle_log : Array, position : int) :
	return ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING

func handle_server(turn_calc : Node,user:ms_spirit_active, user_player_node : Node, target : ms_spirit_active, target_player_node : Node, data : Dictionary) -> Array :
	var attack_power = base_atk * (user.get_atk_concrete() if atk_flavor == ms_constants.ATK_FLAVOR.CONCRETE else user.get_atk_abstract())
	var defense_power = (target.get_defense() / 2) + ((target.get_atk_concrete() if atk_flavor == ms_constants.ATK_FLAVOR.CONCRETE else target.get_atk_abstract())/2)
	var random = 0.9 + (ms_constants.calculate_randomness(user,target) * 0.2)
	var damage = attack_power / defense_power * random
	
	var current_action = turn_calc.get_current_action(user,turn_calc.player_order_data[turn_calc.speed_order[turn_calc.current_handling_order]]["action_index"])
	
	var weak_res = ms_constants.get_hit_type(
		current_action.type,
		SpiritDictionary.spirits[target.key].type,
		null if target.key_equip == "" else SpiritDictionary.spirits[target.key_equip].type)
	
	match weak_res :
		ms_constants.WEAK_RES.WEAK :
			damage *= 1.25
		ms_constants.WEAK_RES.RES :
			damage *= 0.75 # TODO : I want to test out 0.0 instead of 0.75
		ms_constants.WEAK_RES.NORMAL :
			pass
	
	if current_action.type == SpiritDictionary.spirits[target.key].type :
		damage *= 1.1
	
	if target.is_defending :
		damage *= 0.5
	
	var player_damage = 0
	var spirit_damage = damage
	
	target.current_hp -= damage
	if target.current_hp < 0 :
		player_damage = abs(target.current_hp)
		target.current_hp = 0
		spirit_damage -= player_damage
		
		target_player_node.player_health -= player_damage
	
	return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING,[],[user,user_player_node,target,target_player_node],
		{
			"damage_amount" : damage,
			"spirit_damage" : spirit_damage,
			"overflow_damage" : player_damage,
			"weak_status" : weak_res,
		}
	]
