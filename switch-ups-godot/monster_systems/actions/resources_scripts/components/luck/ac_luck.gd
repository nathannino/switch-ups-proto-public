extends ms_action_component
class_name ms_ac_luck

@export var base_chance_percent : float
@export var action : Array[ms_action_component]

const desc = preload("uid://cciubrosm577s")

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
