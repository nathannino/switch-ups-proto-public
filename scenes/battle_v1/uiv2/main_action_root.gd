extends HBoxContainer

@export var panel_container : Control
@export var battle_root : Control
@export var ui_globals : Node

@export var move_holder : Control

var selected_position : ms_constants.POSITION :
	get: return ui_globals.selected_position
	set(value) : ui_globals.selected_position = value

func _ready() -> void:
	ui_globals.selected_position_changed.connect(populate_moves)
	ui_globals.show_spiritactionroot.connect(func() :
		show()
	)
	ui_globals.hide_spiritactionroot.connect(func() :
		hide()
	)
	
	move_holder.move_selected.connect(func(_index : int, _action : ms_action):
		ui_globals.submit_moves(_index, _action)
	)

func populate_moves() :
	var spirit_active = battle_root.get_spirit_in_field(battle_root.friend_team,selected_position)
	var actions = spirit_active.get_actions_combined_converted()
	move_holder.set_actions(actions,spirit_active.current_stamina) 
