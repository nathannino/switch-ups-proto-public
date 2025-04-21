extends Node3D

signal movement_done
signal scale_done

func change_spirit_size(new_size : float, duration : float) :
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Spirit,"scale",Vector3(new_size,new_size,new_size),duration)
	tween.tween_callback(scale_done.emit.call_deferred)
	pass

func set_spirit_size(old_size : float, new_size : float, duration : float) :
	$Spirit.scale = Vector3(old_size,old_size,old_size)
	change_spirit_size(new_size,duration)
	pass

func move_to(old_pos : Vector3, new_pos : Vector3, duration : float, easing : Tween.EaseType = Tween.EASE_OUT, trans : Tween.TransitionType = Tween.TRANS_SPRING) :
	global_position = old_pos
	var tween = create_tween()
	tween.set_ease(easing)
	tween.set_trans(trans)
	tween.tween_property(self,"global_position",new_pos,duration)
	tween.tween_callback(movement_done.emit.call_deferred)

func move_to_bezier(old_pos : Node3D, new_pos : Node3D, circle_anchor : Node3D, duration : float, easing : Tween.EaseType, trans : Tween.TransitionType = Tween.TRANS_LINEAR) :
	global_position = old_pos.global_position
	var tween = create_tween()
	tween.set_ease(easing)
	tween.set_trans(trans)
	tween.tween_method(func(_progress) :
		global_position = global_func.quadratic_bezier(old_pos.global_position,circle_anchor.global_position,new_pos.global_position,_progress)
	,0.0,1.0,duration)
	tween.tween_callback(movement_done.emit.call_deferred)
	
