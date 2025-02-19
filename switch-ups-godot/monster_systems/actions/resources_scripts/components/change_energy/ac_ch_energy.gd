extends ms_action_component

class_name ms_ac_ch_energy

@export var energy_change : int

const desc = preload("uid://c50be86xg570j")

func get_desc() -> Node :
	var instance = desc.instantiate()
	instance.component = self
	return instance
