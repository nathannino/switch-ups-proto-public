extends ms_action_component

class_name ms_ac_ch_active

const desc = preload("uid://nrssduut60jb")

func get_desc() -> Node :
	var instance = desc.instantiate()
	instance.component = self
	return instance
