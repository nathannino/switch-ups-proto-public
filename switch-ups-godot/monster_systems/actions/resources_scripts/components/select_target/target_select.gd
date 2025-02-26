extends Control

var target_type : ms_constants.TARGETS
var allow_back : bool

var battle_root : Node

@export var title_label : Label
@export var back_button : Button
@export var grid : GridContainer

func set_label() :
	match target_type :
		ms_constants.TARGETS.ALLY_SPIRIT, ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPIRIT, ms_constants.TARGETS.ENEMY_SPIRIT, ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPIRIT :
			title_label.text = tr("TR_CONST_TARGET_SELECT_SPIRIT")
		ms_constants.TARGETS.ALLY_SPOT, ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPOT, ms_constants.TARGETS.ENEMY_SPOT, ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPOT :
			title_label.text = tr("TR_CONST_TARGET_SELECT_SPOT")

func set_option() :
	var options = []
	match target_type :
		ms_constants.TARGETS.ALLY_SPIRIT, ms_constants.TARGETS.ALLY_SPOT :
			options = battle_root.friend_team.slice(0,3)
		ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPIRIT, ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPOT :
			options = battle_root.friend_team.slice(1,3)
		ms_constants.TARGETS.ENEMY_SPIRIT, ms_constants.TARGETS.ENEMY_SPOT :
			options = battle_root.enemy_team.slice(0,3)
		ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPIRIT, ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPOT :
			options = battle_root.enemy_team.slice(1,3)
	
	grid.set_options(options)

func attach_ready(_battle_root : Node) :
	battle_root = _battle_root
	if allow_back : 
		back_button.show()
	else :
		back_button.hide()
	set_option()
	set_label()
	pass

func return_value(value) :
	battle_root.submit_action_data(value)
