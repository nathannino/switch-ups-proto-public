extends Control

@export var center : Control
@export var left : Control
@export var right : Control
@export var party : Control # FIXME : We need more anchors

func get_ms_anchor(_position : ms_constants.POSITION) -> Control :
	match _position :
		ms_constants.POSITION.LEFT :
			return left
		ms_constants.POSITION.RIGHT :
			return right
		ms_constants.POSITION.CENTER :
			return center
		_ :
			return party
