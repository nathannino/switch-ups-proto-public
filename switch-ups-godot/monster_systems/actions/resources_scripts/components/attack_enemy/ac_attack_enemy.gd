extends ms_action_component

class_name ms_ac_attack_enemy

@export var base_atk : int
@export var atk_flavor : ms_constants.ATK_FLAVOR

const desc = preload("uid://nrssduut60jb")

func get_desc() -> Node :
	var instance = desc.instantiate()
	instance.text = "Deal %s %s damage to the active enemy" % [base_atk, atk_flavor]
	return instance
