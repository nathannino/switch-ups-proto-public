extends Control

var allow_back : bool

var battle_root : Node

@export var back_button : Button
@export var active_team_list : VBoxContainer
@export var reserve_team_list : VBoxContainer

@export var selected_color : Color
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
	var options = []
	var active_team = battle_root.friend_team.slice(0,3)
	var reserve_team = battle_root.friend_team.slice(3)
	
	active_team_list.set_options(active_team)
	reserve_team_list.set_options(reserve_team)

func attach_ready(_battle_root : Node) :
	battle_root = _battle_root
	if allow_back : 
		back_button.show()
	else :
		back_button.hide()
	set_option()
	pass

func pos_to_index(pos,container) :
	return pos if container == active_team_list else pos + 3

func return_value(data) :
	battle_root.submit_action_data(data)
