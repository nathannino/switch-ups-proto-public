extends PanelContainer

var action : ms_action

@export var name_label : RichTextLabel
@export var type_label : RichTextLabel
@export var cost_label : RichTextLabel
@export var desc_container : Container

signal pressed(action : ms_action)

var ready_done = false
func set_action(_action : ms_action) :
	action = _action
	if ready_done : update_ui()

func _ready() :
	if not action == null :
		update_ui()
	ready_done = true
	pass

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSLATION_CHANGED :
			update_ui()

func update_ui() :
	name_label.text = action.name
	type_label.text = tr("TR_SUMMARY_TYPE").format({"type":ms_constants.type_to_bbcode(action.type)})
	cost_label.text = "[right]" + tr("TR_SUMMARY_COST").format({"cost" : action.cost}) + "[/right]" 
	for child in desc_container.get_children() :
		desc_container.remove_child(child)
		child.queue_free()
	for component in action.effects :
		desc_container.add_child(component.get_desc())


func _on_button_pressed() -> void:
	pressed.emit(action)
	pass # Replace with function body.
