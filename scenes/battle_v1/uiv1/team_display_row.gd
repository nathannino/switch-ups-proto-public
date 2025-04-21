extends Control

@export var battle_root : Node
@export var is_self : bool
@export var summary_container : Container

@export_category("monster_buttons")
@export var spirit_left : Control
@export var spirit_center : Control
@export var spirit_right : Control

func _ready() -> void:
	battle_root.sync_team.connect(sync_team_state)
	
	spirit_center.pressed_option.connect(func (_index) : show_summary(spirit_center))
	spirit_left.pressed_option.connect(func (_index) : show_summary(spirit_left))
	spirit_right.pressed_option.connect(func (_index) : show_summary(spirit_right))

func set_button_state(enabled : bool) :
	for child in get_children() :
		child.set_button_state(enabled)

func sync_team_state() :
	var team = battle_root.friend_team if is_self else battle_root.enemy_team
	spirit_center.set_monster(battle_root.get_spirit_in_field(team,ms_constants.POSITION.CENTER))
	spirit_left.set_monster(battle_root.get_spirit_in_field(team,ms_constants.POSITION.LEFT))
	spirit_right.set_monster(battle_root.get_spirit_in_field(team,ms_constants.POSITION.RIGHT))

func show_summary(monster_button : Node) :
	summary_container.show()
	summary_container.set_summary_active(monster_button.current_spirit)
