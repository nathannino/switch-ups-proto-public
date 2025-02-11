extends PanelContainer

var action : ms_action

@export var name_label : RichTextLabel
@export var type_label : RichTextLabel
@export var cost_label : RichTextLabel
@export var desc_container : Container

var ready_done = false
func set_action(_action : ms_action) :
	action = _action
	if ready_done : update_ui()

func _ready() :
	if not action == null :
		update_ui()
	ready_done = true
	pass

func update_ui() :
	name_label.text = action.name
	type_label.text = "Type : %s" % ms_constants.type_to_bbcode(action.type)
	cost_label.text = "[right]Cost : %s[/right]" % action.cost
	for component in action.effects :
		desc_container.add_child(component.get_desc())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
