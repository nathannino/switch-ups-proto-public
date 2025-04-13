extends Node3D

@export var friend_player : Node3D
@export var enemy_player : Node3D

@export var camera : Camera3D
@export var camera_target : Node3D

var camera_default_rot : Vector3
signal cam_rotation_done

var current_tween : Tween

func _ready() -> void:
	friend_player.set_camera(camera)
	friend_player.is_friend = true
	
	enemy_player.set_camera(camera)
	enemy_player.is_friend = false
	
	camera_default_rot = camera.global_rotation
	OptionsOverlay.camera_static_changed.connect(func() :
		if OptionsOverlay.camera_static :
			camera_reset()
	)

func camera_look_at(_pos : ms_constants.POSITION, is_friend) :
	if OptionsOverlay.camera_static :
		cam_rotation_done.emit()
		return
	
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
	
	if (current_tween) :
		current_tween.kill()
	
	var current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_IN_OUT)
	current_tween.set_trans(Tween.TRANS_CUBIC)
	current_tween.tween_property(camera,"global_rotation",camera_target.global_rotation,1.3)
	current_tween.tween_callback(cam_rotation_done.emit)
