extends Node3D

@export var friend_player : Node3D
@export var enemy_player : Node3D

@export var camera : Camera3D
@export var camera_target : Node3D

var camera_default_rot : Vector3
signal cam_rotation_done

func _ready() -> void:
	friend_player.set_camera(camera)
	friend_player.is_friend = true
	
	enemy_player.set_camera(camera)
	enemy_player.is_friend = false
	
	camera_default_rot = camera.global_rotation

func camera_look_at(_pos : ms_constants.POSITION, is_friend) :
	var _player = friend_player if is_friend else enemy_player
	
	var _spirit = _player.get_spirit_anchor_from_pos(_pos)
	
	camera_target.look_at(_spirit.global_transform.origin,Vector3.UP)
	_rotate_camera()
	pass

func camera_reset() :
	camera_target.global_rotation = camera_default_rot
	_rotate_camera()
	pass

func _rotate_camera() :
	if camera_target.global_rotation.is_equal_approx(camera.global_rotation) :
		cam_rotation_done.emit()
		return
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera,"global_rotation",camera_target.global_rotation,1.3)
	tween.tween_callback(cam_rotation_done.emit)
