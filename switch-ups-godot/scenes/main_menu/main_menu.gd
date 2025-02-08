extends Control

#signal preinit_complete

#func preinit_completed() :
#	preinit_complete.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BgmManager.play("bg_compendium",BgmManager.TRANSITIONS.FADE_OUT_CUT_IN)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
