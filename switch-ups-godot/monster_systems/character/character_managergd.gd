extends Node3D

var spirit_front : Node3D
var spirit_left : Node3D
var spirit_right : Node3D

@export_category("Spirit anchors")
@export var spirit_center_anchor : Node3D
@export var spirit_front_anchor : Node3D
@export var spirit_left_anchor : Node3D
@export var spirit_right_anchor : Node3D

@export_category("Spirits targets")
@export var spirit_front_target : Node3D
@export var spirit_left_target : Node3D
@export var spirit_right_target : Node3D

@export_category("Spirit properties")
@export var friend_spirit_size : float
@export var enemy_spirit_size : float

var _is_friend = false
var is_friend : bool :
	get : return _is_friend
	set(value) :
		_is_friend = value
		set_spirit_size()

func set_camera(_camera : Camera3D) :
	spirit_front.camera = _camera
	spirit_left.camera = _camera
	spirit_right.camera = _camera

func set_spirit_size() :
	var size = friend_spirit_size if is_friend else enemy_spirit_size
	spirit_front.scale = Vector3(size,size,size)
	spirit_left.scale = Vector3(size,size,size)
	spirit_right.scale = Vector3(size,size,size)

func _reset_spirits_variables() :
	spirit_front = spirit_front_anchor.get_child(0)
	spirit_left = spirit_left_anchor.get_child(0)
	spirit_right = spirit_right_anchor.get_child(0)

func sync_spirits(team : Array) :
	spirit_front.set_spirit_active(team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)])
	spirit_left.set_spirit_active(team[ms_constants.position_to_index(ms_constants.POSITION.LEFT)])
	spirit_right.set_spirit_active(team[ms_constants.position_to_index(ms_constants.POSITION.RIGHT)])
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_reset_spirits_variables()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
