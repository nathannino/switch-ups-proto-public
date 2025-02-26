extends ms_action_component
class_name ms_ac_luck

@export var base_chance_percent : float
@export var action : Array[ms_action_component]

const desc = preload("uid://cciubrosm577s")

func get_desc() -> Node :
	var instance = desc.instantiate()
	instance.component = self
	return instance

func get_precommit() -> PackedScene :
	return null

func get_interrupt_action() -> PackedScene :
	return null
