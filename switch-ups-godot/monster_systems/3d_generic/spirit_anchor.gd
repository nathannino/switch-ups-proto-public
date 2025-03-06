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

func move_to(old_pos : Vector3, new_pos : Vector3, duration : float) :
	global_position = old_pos
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self,"global_position",new_pos,duration)
	tween.tween_callback(movement_done.emit.call_deferred)
