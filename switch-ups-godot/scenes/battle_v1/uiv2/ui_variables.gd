extends Node

enum BACK_TARGET {
	ADS_ACTION_ROOT,
	SPIRIT_ACTION_ROOT
}

@export var battle_root : Control

var _selected_position : ms_constants.POSITION = ms_constants.POSITION.CENTER
signal selected_position_changed
var selected_position : ms_constants.POSITION :
	get : return _selected_position
	set(_value) :
		_selected_position = _value
		selected_position_changed.emit()

#region adsactionroot visibility
signal show_adsactionroot
signal hide_adsactionroot
#endregion
#region spiritactionroot visibility
signal show_spiritactionroot
signal hide_spiritactionroot
#endregion
#region rotation enabler
signal enable_rotation
signal disable_rotation
#endregion
#region rotation visibility
signal show_rotation
signal hide_rotation
#endregion

var back_target = BACK_TARGET.ADS_ACTION_ROOT

func _ready() :
	hide_adsactionroot.emit()
	hide_spiritactionroot.emit()
	disable_rotation.emit()
	hide_rotation.emit()
	
	battle_root.turn_start.connect(func() :
		enable_rotation.emit()
		show_rotation.emit()
		show_adsactionroot.emit()
		back_target = BACK_TARGET.ADS_ACTION_ROOT
	)

func show_ads() :
	show_adsactionroot.emit()
	hide_spiritactionroot.emit()
	back_target = BACK_TARGET.ADS_ACTION_ROOT

func show_movelist() :
	hide_adsactionroot.emit()
	show_spiritactionroot.emit()
	back_target = BACK_TARGET.SPIRIT_ACTION_ROOT

func cancel_submit_moves() :
	enable_rotation.emit()
	match back_target :
		BACK_TARGET.ADS_ACTION_ROOT :
			show_ads() 
		BACK_TARGET.SPIRIT_ACTION_ROOT :
			show_movelist()

func submit_moves(_index : int, _action : ms_action) :
	hide_adsactionroot.emit()
	hide_spiritactionroot.emit()
	disable_rotation.emit()
	print(tr(_action.name))
	pass
