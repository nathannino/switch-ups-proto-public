extends Control

var allow_back : bool

var battle_root : Node

const OPTIONS_STRINGS = ["TR_SUMMARY","TR_SELECT"]

@export var back_button : Button
@export var active_team_display : Control
@export var reserve_team_list : HBoxContainer
@export var confirm_button : Button

var _team_active_representative : ms_spirit_active
var team_active_representative : ms_spirit_active :
	get : return _team_active_representative
	set(value) :
		_team_active_representative = value
		confirm_button.disabled = (_team_active_representative == null) or (_team_reserve_representative == null)
var _team_reserve_representative : ms_spirit_active
var team_reserve_representative : ms_spirit_active :
	get : return _team_reserve_representative
	set(value) :
		_team_reserve_representative = value
		confirm_button.disabled = (_team_active_representative == null) or (_team_reserve_representative == null)

func set_option() :
	var active_team = battle_root.friend_team.slice(0,3)
	var reserve_team = battle_root.friend_team.slice(3)

	reserve_team_list.set_options(reserve_team,OPTIONS_STRINGS)
	
	active_team_display.set_spirit(active_team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)],ms_constants.POSITION.CENTER)
	active_team_display.set_spirit(active_team[ms_constants.position_to_index(ms_constants.POSITION.LEFT)],ms_constants.POSITION.LEFT)
	active_team_display.set_spirit(active_team[ms_constants.position_to_index(ms_constants.POSITION.RIGHT)],ms_constants.POSITION.RIGHT)

func attach_ready(_battle_root : Node) :
	battle_root = _battle_root
	if allow_back : 
		back_button.show()
	else :
		back_button.hide()
	set_option()
	active_team_display.set_options(OPTIONS_STRINGS.duplicate())
	active_team_display.ms_pressed.connect(func (index : int, _pos : ms_constants.POSITION) :
		var _spirit = battle_root.friend_team[ms_constants.position_to_index(_pos)]
		if index == 0 :
			battle_root.show_summary(_spirit)
		else :
			active_team_display.selected_position = _pos
			team_active_representative = _spirit
	)
	pass

func return_value(data) :
	battle_root.submit_action_data(data)
