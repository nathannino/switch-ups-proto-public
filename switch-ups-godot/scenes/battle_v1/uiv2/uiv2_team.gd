extends Control

@export var battle_root : Node
@export var is_self : bool
@export var summary_container : Container
@export var ui_globals : Node

@export_category("monster_buttons")
@export var spirit_team_display : Control

@export_category("actions_containers")
@export var action_root : Control

var _selected_position : ms_constants.POSITION
var selected_position : ms_constants.POSITION :
	get : return ui_globals.selected_position
	set(_value) : ui_globals.selected_position = _value

func begin_turn() :
	if not is_self :
		return
	action_root.show()
	selected_position = ms_constants.POSITION.CENTER
	pass

func begin_battlelog() :
	if not is_self :
		return
	action_root.hide()
	spirit_team_display.reset_colors()
	pass

func _ready() -> void:
	spirit_team_display.summary_container = summary_container
	spirit_team_display.is_friend = is_self
	
	ui_globals.selected_position_changed.connect(func() :
		spirit_team_display.selected_position = ui_globals.selected_position
	)
	
	battle_root.sync_team.connect(sync_team_state)
	battle_root.turn_start.connect(begin_turn)
	battle_root.battlelog_start.connect(begin_battlelog)

func show_summary(monster_button : Node) :
	summary_container.show()
	summary_container.set_summary_active(monster_button.current_spirit)

func sync_team_state() :
	var team = battle_root.friend_team if is_self else battle_root.enemy_team
	spirit_team_display.set_spirit(battle_root.get_spirit_in_field(team,ms_constants.POSITION.CENTER),ms_constants.POSITION.CENTER)
	spirit_team_display.set_spirit(battle_root.get_spirit_in_field(team,ms_constants.POSITION.LEFT),ms_constants.POSITION.LEFT)
	spirit_team_display.set_spirit(battle_root.get_spirit_in_field(team,ms_constants.POSITION.RIGHT),ms_constants.POSITION.RIGHT)
