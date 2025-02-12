extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BgmManager.play("bg_waiting",BgmManager.TRANSITIONS.FADE_OUT_CUT_IN)
	pass # Replace with function body.
