extends Control

@export var center_rotate_anchor : Control
@export var left_rotate_anchor : Control
@export var right_rotate_anchor : Control
@export var bottom_rotate_anchor : Control
@export var offscreen_anchor : Control

func _either(_old_pos : ms_constants.POSITION, _new_pos : ms_constants.POSITION, _checked_pos : ms_constants.POSITION) :
	return (_old_pos == _checked_pos or _new_pos == _checked_pos)

# Rotation anchors assume this is a rotation, not a switch. As such, no support for party
func get_anchors(_old_pos : ms_constants.POSITION, _new_pos : ms_constants.POSITION) :
	assert(not _either(_old_pos,_new_pos,ms_constants.POSITION.PARTY))
	
	var return_value = [center_rotate_anchor]
	if _either(_old_pos,_new_pos,ms_constants.POSITION.CENTER) :
		if _either(_old_pos,_new_pos,ms_constants.POSITION.LEFT) :
			return_value.push_back(left_rotate_anchor)
		else :
			return_value.push_back(right_rotate_anchor)
	else :
		return_value.push_back(bottom_rotate_anchor)
	return return_value
