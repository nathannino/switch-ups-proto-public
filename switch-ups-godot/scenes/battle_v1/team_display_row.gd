extends HBoxContainer

@export var battle_root : Node
@export var is_self : bool

@export_category("monster_buttons")
@export var spirit_left : Control
@export var spirit_center : Control
@export var spirit_right : Control

func _ready() -> void:
	battle_root.sync_team.connect(sync_team_state)
	set_button_state(false)

func set_button_state(enabled : bool) :
	for child in get_children() :
		child.set_button_state(enabled)

func sync_team_state() :
	var team = battle_root.friend_team if is_self else battle_root.enemy_team
	spirit_center.set_monster(team[0])
	spirit_left.set_monster(team[1])
	spirit_right.set_monster(team[2])
