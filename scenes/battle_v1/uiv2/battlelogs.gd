extends Control

@export var log_container : Container
@export var battle_root : Control

const BATTLE_LOG_SCENE = preload("uid://bx6ravvup2qf2")

func _ready() :
	battle_root.battlelog_next.connect(func() :
		for child in log_container.get_children() :
			child.can_dissapear = true
	)

func add_battle_log(_key : String, _format_vars : Dictionary = {}, _translated_format_vars : Dictionary = {}, _time : float = 0) :
	var instance = BATTLE_LOG_SCENE.instantiate()
	log_container.add_child(instance)
	instance.set_text(_key,_translated_format_vars,_format_vars)
	instance.set_timeout(_time)
	pass
