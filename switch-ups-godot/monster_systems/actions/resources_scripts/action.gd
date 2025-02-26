extends Resource

class_name ms_action

@export var key : String
@export var name : String
@export var type : ms_constants.TYPE
@export var cost : int
@export var priority : int

@export var effects : Array[ms_action_component]

func get_child_component(_index : int) -> ms_action_component :
	return effects[_index] if _index < effects.size() else null
