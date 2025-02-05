extends Control

@export var title : String

func _get_index() -> int :
	var child_list = $"..".get_children()
	for i in range(child_list.size()) :
		if child_list[i] == self :
			return i
	return -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var index = _get_index()
	$"..".set_tab_title(index,title)
	pass # Replace with function body.
