extends Node3D

signal animation_done

var hand_watch : PhysicalBone3D
@export var skeleton : Skeleton3D
@export var hand_bone_name : String
@export var animation : AnimationPlayer

@export_category("Spirit anchors")
@export var spirit_front_anchor : Node3D
@export var spirit_left_anchor : Node3D
@export var spirit_right_anchor : Node3D

@export_category("Spirits targets")
@export var spirit_center_target : Node3D
@export var spirit_front_target : Node3D
@export var spirit_left_target : Node3D
@export var spirit_right_target : Node3D
@export var spirit_party_target : Node3D

@export_category("Spirit circle targets")
@export var spirit_left_right_circle_target : Node3D
@export var spirit_center_left_circle_target : Node3D
@export var spirit_center_right_circle_target : Node3D
@export var spirit_party_circle_target : Node3D

@export_category("Spirit properties")
@export var friend_spirit_size : float
@export var friend_right_spirit_size_override : float
@export var enemy_spirit_size : float

var is_friend = false

func rotate_spirit(_spirit_3d : Node3D,_old_pos : ms_constants.POSITION, _position : ms_constants.POSITION, target_circle_child : int) :
	const _DURATION = 1
	
	var _global_pos_old = _spirit_3d.global_position
	var _global_pos_old_target = Node3D.new()
	add_child(_global_pos_old_target)
	_global_pos_old_target.global_position = _global_pos_old
	
	_spirit_3d.get_parent().remove_child(_spirit_3d)
	add_child(_spirit_3d)
	_spirit_3d.global_position = _global_pos_old
	
	var target
	match _position:
		ms_constants.POSITION.LEFT:
			spirit_left_anchor = _spirit_3d
			target = spirit_left_target
		ms_constants.POSITION.RIGHT:
			spirit_right_anchor = _spirit_3d
			target = spirit_right_target
		ms_constants.POSITION.CENTER:
			spirit_front_anchor = _spirit_3d
			target = spirit_front_target
	_spirit_3d.change_spirit_size(get_spirit_scale(ms_constants.position_to_index(_position)), _DURATION)
	
	var circle_target
	if ((_old_pos == ms_constants.POSITION.LEFT or _old_pos == ms_constants.POSITION.RIGHT) 
		and (_position == ms_constants.POSITION.LEFT or _position == ms_constants.POSITION.RIGHT)) :
		circle_target = spirit_left_right_circle_target
	elif (_position == ms_constants.POSITION.LEFT or _old_pos == ms_constants.POSITION.LEFT) : # elif to take less space
		circle_target = spirit_center_left_circle_target
	else :
		circle_target = spirit_center_right_circle_target
	
	_spirit_3d.movement_done.connect(func() :
		_global_pos_old_target.queue_free()
		animation_done.emit.call_deferred()
	, CONNECT_ONE_SHOT)
	_spirit_3d.move_to_bezier(_global_pos_old_target, target, circle_target.get_child(target_circle_child), _DURATION, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)
	

func get_spirit_target_from_pos(_position : ms_constants.POSITION) :
	match _position :
		ms_constants.POSITION.CENTER :
			return spirit_front_target
		ms_constants.POSITION.LEFT :
			return spirit_left_target
		ms_constants.POSITION.RIGHT :
			return spirit_right_target
		ms_constants.POSITION.PARTY :
			return spirit_party_target

func get_spirit_anchor_from_pos(_position : ms_constants.POSITION) :
	match _position :
		ms_constants.POSITION.CENTER :
			return spirit_front_anchor
		ms_constants.POSITION.LEFT :
			return spirit_left_anchor
		ms_constants.POSITION.RIGHT :
			return spirit_right_anchor
		_ :
			return null

func set_camera(_camera : Camera3D) :
	spirit_front_anchor.get_child(0).camera = _camera
	spirit_left_anchor.get_child(0).camera = _camera
	spirit_right_anchor.get_child(0).camera = _camera

func get_spirit_scale(_position : int) -> float :
	if _position == ms_constants.position_to_index(ms_constants.POSITION.CENTER) :
		return enemy_spirit_size
	if _position == ms_constants.position_to_index(ms_constants.POSITION.RIGHT) and is_friend :
		return friend_right_spirit_size_override
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

#region switch_spirit
var switch_new_spirit : ms_spirit_active
var switch_position : ms_constants.POSITION

var _switch_spirit_can_finish : int
const SWITCH_SPIRIT_CAN_FINISH_STEPS = 2
var switch_spirit_can_finish : int :
	get : return _switch_spirit_can_finish
	set(value) : 
		_switch_spirit_can_finish = value
		if _switch_spirit_can_finish >= SWITCH_SPIRIT_CAN_FINISH_STEPS :
			animation_done.emit.call_deferred()
			_switch_spirit_can_finish = 0

func _switch_spirit_center() :
	animation.pause()
	pass

func switch_spirit(_position : ms_constants.POSITION, _new_spirit : ms_spirit_active) :
	animation.play_switch()
	_switch_spirit_can_finish = 0
	
	var old_spirit = get_spirit_anchor_from_pos(_position)
	var target = get_spirit_target_from_pos(_position)
	var start_duration = 1.0
	var end_duration = 1.0
	
	old_spirit.movement_done.connect(func() :
		animation.animation_finished.connect(func(_name) :
			animation.play_idle.call_deferred()
			switch_spirit_can_finish += 1
		,CONNECT_ONE_SHOT)
		animation.play.call_deferred()
		
		old_spirit.get_child(0).set_spirit_active(_new_spirit)
		
		old_spirit.change_spirit_size(get_spirit_scale(ms_constants.position_to_index(_position)),end_duration)
		
		
		var circle_target
		match _position :
			ms_constants.POSITION.CENTER:
				circle_target = spirit_party_circle_target
			ms_constants.POSITION.LEFT :
				circle_target = spirit_center_left_circle_target.get_child(0)
			ms_constants.POSITION.RIGHT :
				circle_target = spirit_center_right_circle_target.get_child(0)
		old_spirit.move_to_bezier(spirit_party_target, target, circle_target, end_duration, Tween.EASE_OUT, Tween.TRANS_LINEAR)
		old_spirit.movement_done.connect.call_deferred(func() :
			switch_spirit_can_finish += 1
		, CONNECT_ONE_SHOT)
	,CONNECT_ONE_SHOT)
	old_spirit.move_to_bezier(target, spirit_party_target, spirit_party_circle_target, start_duration, Tween.EASE_IN, Tween.TRANS_LINEAR)
	old_spirit.change_spirit_size(0,start_duration)
	
#endregion

func _ready() :
	spirit_front_anchor.hide()
	spirit_left_anchor.hide()
	spirit_right_anchor.hide()
	animation.freeze_attack()

func begin_battle() :
	var start_target = spirit_center_target.global_position
	#var start_target = get_bone_global_position()
	var move_duration = 1.5
	var grow_duration = 0.5
	
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
	
func change_stat(_position : ms_constants.POSITION, _change : float) :
	var _spirit
	
	match _position :
		ms_constants.POSITION.CENTER :
			_spirit = spirit_front_anchor.get_child(0)
		ms_constants.POSITION.LEFT :
			_spirit = spirit_left_anchor.get_child(0)
		ms_constants.POSITION.RIGHT :
			_spirit = spirit_right_anchor.get_child(0)
		_ :
			animation_done.emit() # Technically possible? In any case, this shouldn't crash
			return
	
	_spirit.play_stat_change(_change)
	_spirit.stat_change_anim_done.connect(func() :
		animation_done.emit()
	, CONNECT_ONE_SHOT)
