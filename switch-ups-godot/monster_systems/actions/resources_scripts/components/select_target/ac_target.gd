extends ms_action_component
class_name ms_ac_target

@export var target_type : ms_constants.TARGETS
@export var during_turn : bool
@export var action : Array[ms_action_component]

const desc = preload("uid://cvrjfoo54cj7m")

func get_desc() -> Node :
	var instance = desc.instantiate()
	instance.component = self
	return instance
