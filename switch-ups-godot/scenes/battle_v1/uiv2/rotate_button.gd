extends Button

enum ROTATE {
	LEFT,
	RIGHT
}

var selected_position : ms_constants.POSITION :
	get : return team_root.selected_position
	set(value) : team_root.selected_position = value

@export var team_root : Control
@export var rotate : ROTATE
@export var ui_globals : Node

func _ready() :
	pressed.connect(_on_pressed)
	#region ui_globals signals
	ui_globals.enable_rotation.connect(func() :
		disabled = false
	)
	ui_globals.disable_rotation.connect(func() :
		disabled = true
	)
	ui_globals.show_rotation.connect(func() :
		show()
	)
	ui_globals.hide_rotation.connect(func() :
		hide()
	)
	#endregion

func rotate_left() :
	match selected_position :
		ms_constants.POSITION.CENTER :
			selected_position = ms_constants.POSITION.LEFT
		ms_constants.POSITION.LEFT :
			selected_position = ms_constants.POSITION.RIGHT
		ms_constants.POSITION.RIGHT :
			selected_position = ms_constants.POSITION.CENTER

func rotate_right() :
	match selected_position :
		ms_constants.POSITION.CENTER :
			selected_position = ms_constants.POSITION.RIGHT
		ms_constants.POSITION.LEFT :
			selected_position = ms_constants.POSITION.CENTER
		ms_constants.POSITION.RIGHT :
			selected_position = ms_constants.POSITION.LEFT

func _on_pressed() :
	match rotate :
		ROTATE.LEFT :
			rotate_left()
		ROTATE.RIGHT :
			rotate_right()
	pass
