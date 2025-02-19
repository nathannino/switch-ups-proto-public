extends ms_action_component
class_name ms_ac_ch_stat_level

@export var stat : ms_constants.STATS
@export var level_change : int

const desc = preload("uid://dw6bamhoodhsd")

func get_desc() -> Node :
	var instance = desc.instantiate()
	instance.component = self
	return instance
