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
