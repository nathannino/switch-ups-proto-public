extends Resource

class_name scene_transition_anim

@export var transitions : Array[scene_transition_anim_entry]

func to_dictionary() -> Dictionary :
	var dict = {}
	for transition in transitions :
		dict[transition.key] = transition.scene
	return dict
