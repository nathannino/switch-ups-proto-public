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
	spirit.hp -= battle_log["spirit_damage"]
	var player_dmg = battle_log["overflow_damage"]
	if player_dmg > 0 :
		battle_root.change_player_hp(target_info["target_id"],-player_dmg)

func already_handled_server(battle_log : Array, position : int) :
	return ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING

func handle_server(user:ms_spirit_active, user_player_node : Node, target : ms_spirit_active, target_player_node : Node, data : Dictionary) -> Array :
	var attack_power = base_atk * (user.get_atk_concrete() if atk_flavor == ms_constants.ATK_FLAVOR.CONCRETE else user.get_atk_abstract())
	var defense_power = (target.get_defense() / 2) + ((target.get_atk_concrete() if atk_flavor == ms_constants.ATK_FLAVOR.CONCRETE else target.get_atk_abstract())/2)
	var random = 0.9 + (ms_constants.calculate_randomness(user,target) * 0.2)
	var damage = attack_power / defense_power * random
	
	var player_damage = 0
	var spirit_damage = damage
	
	target.current_hp -= damage
	if target.current_hp < 0 :
		player_damage = abs(target.current_hp)
		target.current_hp = 0
		spirit_damage -= player_damage
	
	return [ms_constants.ACTION_COMPONENT_HANDLE_STATE.GET_SIBLING,[],[user,user_player_node,target,target_player_node],
		{
			"damage_amount" : damage,
			"spirit_damage" : spirit_damage,
			"overflow_damage" : player_damage
		}
	]
