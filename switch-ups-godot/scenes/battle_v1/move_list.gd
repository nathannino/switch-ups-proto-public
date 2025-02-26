extends VBoxContainer

@export var move_holder : Control
@export var battle_root : Control

@export_category("action_menu")
@export var main_action_menu : Control
@export var action_box : Control

@export_category("back buttons")
@export var back_left : Button
@export var back_center : Button
@export var back_right : Button

func show_moves() :
	show()
	action_box.hide()
	populate_moves()
	_position_back()

func populate_moves() :
	var spirit_active = battle_root.get_spirit_in_field(battle_root.friend_team,main_action_menu.spirit_position)
	var actions = spirit_active.get_actions_combined_converted()
	move_holder.set_actions(actions,spirit_active.current_stamina) 

func _position_back() :
	match main_action_menu.spirit_position :
		ms_constants.POSITION.LEFT :
			back_left.self_modulate = Color.WHITE
			back_left.disabled = false
			
			back_center.self_modulate = Color(0,0,0,0)
			back_center.disabled = true
			
			back_right.self_modulate = Color(0,0,0,0)
			back_right.disabled = true
		ms_constants.POSITION.CENTER :
			back_left.self_modulate = Color(0,0,0,0)
			back_left.disabled = true
			
			back_center.self_modulate = Color.WHITE
			back_center.disabled = false
			
			back_right.self_modulate = Color(0,0,0,0)
			back_right.disabled = true
		ms_constants.POSITION.RIGHT :
			back_left.self_modulate = Color(0,0,0,0)
			back_left.disabled = true
			
			back_center.self_modulate = Color(0,0,0,0)
			back_center.disabled = true
			
			back_right.self_modulate = Color.WHITE
			back_right.disabled = false
		_ :
			printerr("Where do I put the back button =(")


func _on_move_holder_move_selected(index: int, action: ms_action) -> void:
	
	pass # Replace with function body.
