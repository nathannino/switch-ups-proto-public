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
		if is_self : spirit_team_display.selected_position = ui_globals.selected_position
	)
	
	spirit_team_display.ms_pressed.connect(func(index : int, _pos : ms_constants.POSITION) :
		var team = battle_root.friend_team if is_self else battle_root.enemy_team
		battle_root.show_summary(team[ms_constants.position_to_index(_pos)])
	)
	
	battle_root.sync_team.connect(sync_team_state)
	battle_root.turn_start.connect(begin_turn)
	battle_root.battlelog_start.connect(begin_battlelog)
	
	battle_root.spirit_rotation.connect(func(_teamid,_old_pos,_new_pos) :
		var id_self = _teamid == battle_root.player_id
		if (id_self and is_self) or not (id_self or is_self) :
			battle_root.pause_battle_log()
			spirit_team_display.rotate_spirit(_old_pos, _new_pos)
			spirit_team_display.rotation_done.connect(func() :
				battle_root.play_battle_log()
			,CONNECT_ONE_SHOT)
			pass
	)
	
	battle_root.spirit_switch.connect(func(_teamid_one,_pos_one,_spirit_one,_teamid_two,_pos_two,_spirit_two) :
		var is_teamone = (_teamid_one == battle_root.player_id) == is_self
		var is_teamtwo = (_teamid_two == battle_root.player_id) == is_self
		
		if is_teamone :
			battle_root.pause_battle_log()
			spirit_team_display.switch_spirit(_spirit_two,_pos_one)
			spirit_team_display.rotation_done.connect(_switch_spirit_rotation_done,CONNECT_REFERENCE_COUNTED)
		if is_teamtwo :
			battle_root.pause_battle_log()
			spirit_team_display.switch_spirit(_spirit_one,_pos_two)
			spirit_team_display.rotation_done.connect(_switch_spirit_rotation_done,CONNECT_REFERENCE_COUNTED)
	)

func _switch_spirit_rotation_done() :
	battle_root.play_battle_log()

func show_summary(monster_button : Node) :
	summary_container.show()
	summary_container.set_summary_active(monster_button.current_spirit)

func sync_team_state() :
	var team = battle_root.friend_team if is_self else battle_root.enemy_team
	spirit_team_display.set_spirit(battle_root.get_spirit_in_field(team,ms_constants.POSITION.CENTER),ms_constants.POSITION.CENTER)
	spirit_team_display.set_spirit(battle_root.get_spirit_in_field(team,ms_constants.POSITION.LEFT),ms_constants.POSITION.LEFT)
	spirit_team_display.set_spirit(battle_root.get_spirit_in_field(team,ms_constants.POSITION.RIGHT),ms_constants.POSITION.RIGHT)
