extends Control

@export var title : String
@export var translate : bool

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSLATION_CHANGED:
			translate_title()

func _get_index() -> int :
	var child_list = $"..".get_children()
	for i in range(child_list.size()) :
		if child_list[i] == self :
			return i
	return -1

func translate_title() :
	var index = _get_index()
	var text = tr(title) if translate else title
	$"..".set_tab_title(index,text)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	translate_title()
	pass # Replace with function body.
