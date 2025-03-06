extends Node3D

signal animation_done

var hand_watch : PhysicalBone3D
@export var skeleton : Skeleton3D
@export var hand_bone_name : String

@export_category("Spirit anchors")
@export var spirit_front_anchor : Node3D
@export var spirit_left_anchor : Node3D
@export var spirit_right_anchor : Node3D

@export_category("Spirits targets")
@export var spirit_center_target : Node3D
@export var spirit_front_target : Node3D
@export var spirit_left_target : Node3D
@export var spirit_right_target : Node3D

@export_category("Spirit properties")
@export var friend_spirit_size : float
@export var enemy_spirit_size : float

var is_friend = false

func set_camera(_camera : Camera3D) :
	spirit_front_anchor.get_child(0).camera = _camera
	spirit_left_anchor.get_child(0).camera = _camera
	spirit_right_anchor.get_child(0).camera = _camera

func get_spirit_scale(_position : int) -> float :
	if _position == ms_constants.position_to_index(ms_constants.POSITION.CENTER) :
		return enemy_spirit_size
	return friend_spirit_size if is_friend else enemy_spirit_size

func set_spirit_size() :
	# FIXME : Handle spirit rotations =/
	var size = friend_spirit_size if is_friend else enemy_spirit_size
	spirit_front_anchor.get_child(0).scale = Vector3(enemy_spirit_size,enemy_spirit_size,enemy_spirit_size)
	spirit_left_anchor.get_child(0).scale = Vector3(size,size,size)
	spirit_right_anchor.get_child(0).scale = Vector3(size,size,size)

func sync_spirits(team : Array) :
	spirit_front_anchor.get_child(0).set_spirit_active(team[ms_constants.position_to_index(ms_constants.POSITION.CENTER)])
	spirit_left_anchor.get_child(0).set_spirit_active(team[ms_constants.position_to_index(ms_constants.POSITION.LEFT)])
	spirit_right_anchor.get_child(0).set_spirit_active(team[ms_constants.position_to_index(ms_constants.POSITION.RIGHT)])
	pass

func get_bone_global_position() -> Vector3 :
	var _index = skeleton.find_bone(hand_bone_name)
	return skeleton.to_global(skeleton.get_bone_global_pose(_index).origin)

func _ready() :
	spirit_front_anchor.hide()
	spirit_left_anchor.hide()
	spirit_right_anchor.hide()

func begin_battle() :
	var start_target = spirit_center_target.global_position
	var move_duration = 1.5
	var grow_duration = 1.0
	
	spirit_front_anchor.move_to(start_target,spirit_front_target.global_position,move_duration)
	spirit_front_anchor.set_spirit_size(0,get_spirit_scale(ms_constants.position_to_index(ms_constants.POSITION.CENTER)),grow_duration)
	spirit_front_anchor.show()
	
	spirit_left_anchor.move_to(start_target,spirit_left_target.global_position,move_duration)
	spirit_left_anchor.set_spirit_size(0,get_spirit_scale(ms_constants.position_to_index(ms_constants.POSITION.LEFT)),grow_duration)
	spirit_left_anchor.show()
	
	spirit_right_anchor.move_to(start_target,spirit_right_target.global_position,move_duration)
	spirit_right_anchor.set_spirit_size(0,get_spirit_scale(ms_constants.position_to_index(ms_constants.POSITION.RIGHT)),grow_duration)
	spirit_right_anchor.show()
	
	if move_duration > grow_duration :
		spirit_right_anchor.movement_done.connect(func() :
			animation_done.emit.call_deferred()
		,CONNECT_ONE_SHOT)
	else :
		spirit_right_anchor.scale_done.connect(func() :
			animation_done.emit.call_deferred()
		,CONNECT_ONE_SHOT)
	
	
