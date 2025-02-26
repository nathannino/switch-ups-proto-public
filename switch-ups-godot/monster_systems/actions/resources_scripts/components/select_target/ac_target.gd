extends ms_action_component
class_name ms_ac_target

@export var target_type : ms_constants.TARGETS
@export var during_turn : bool
@export var action : Array[ms_action_component]

const desc = preload("uid://cvrjfoo54cj7m")
const precommit = preload("uid://cedlvcxxgruty")

func get_desc() -> Node :
	var instance = desc.instantiate()
	instance.component = self
	return instance

func get_child_component(_index : int) -> ms_action_component :
	return action[_index] if _index < action.size() else null

func _select_screen(allow_back : bool) -> Control :
	match target_type :
		ms_constants.TARGETS.SELF_SPIRIT :
			return null
		_:
			var instance = precommit.instantiate()
			instance.target_type = target_type
			instance.allow_back = allow_back
			return instance


func get_precommit() -> Control :
	return _select_screen(true) if not during_turn else null

func serv_requires_interrupt() -> bool :
	return during_turn

func get_interrupt_action() -> Control :
	return _select_screen(false)
