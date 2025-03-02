extends Control

var target_type : ms_constants.TARGETS
var allow_back : bool
var ignore_index : int

var battle_root : Node

@export var title_label : Label
@export var back_button : Button
@export var grid : GridContainer

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSLATION_CHANGED :
			set_label()

func set_label() :
	match target_type :
		ms_constants.TARGETS.ALLY_SPIRIT, ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPIRIT, ms_constants.TARGETS.ENEMY_SPIRIT, ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPIRIT :
			title_label.text = tr("TR_CONST_TARGET_SELECT_SPIRIT")
		ms_constants.TARGETS.ALLY_SPOT, ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPOT, ms_constants.TARGETS.ENEMY_SPOT, ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPOT :
			title_label.text = tr("TR_CONST_TARGET_SELECT_SPOT")

func set_option() :
	var options = []
	ignore_index = -1
	match target_type :
		ms_constants.TARGETS.ALLY_SPIRIT, ms_constants.TARGETS.ALLY_SPOT :
			options = battle_root.friend_team.slice(0,3)
		ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPIRIT :
			var temp_options = battle_root.friend_team.slice(0,3)
			ignore_index = temp_options.find(battle_root.get_spirit_in_field(battle_root.friend_team,battle_root.get_selected_position()))
			options = []
			for _index in range(temp_options.size()) :
				if _index == ignore_index :
					continue
				options.push_back(temp_options[_index])
		ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPOT :
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

func pos_to_index(pos) :
	match target_type :
		ms_constants.TARGETS.ALLY_SPIRIT, ms_constants.TARGETS.ALLY_SPOT, ms_constants.TARGETS.ENEMY_SPIRIT, ms_constants.TARGETS.ENEMY_SPOT :
			return pos
		ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPIRIT :
			assert(not ignore_index == -1)
			if pos < ignore_index :
				return pos
			return pos + 1
		ms_constants.TARGETS.ALLY_EXCLUDE_SELF_SPOT, ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPIRIT, ms_constants.TARGETS.ENEMY_EXCLUDE_ACTIVE_SPOT :
			return pos + 1
		_ :
			return -1

func return_value(pos) :
	if pos is int :
		var _index = pos_to_index(pos)
		battle_root.submit_action_data({"is_precommit":allow_back,"array_pos":_index,"spot_position":ms_constants.index_to_position(_index)})
	else :
		battle_root.submit_action_data(pos)
