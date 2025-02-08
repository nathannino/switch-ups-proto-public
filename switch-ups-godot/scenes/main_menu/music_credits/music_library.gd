extends ScrollContainer

const music_panel = preload("res://scenes/main_menu/music_credits/music_panel.tscn")
@export var grid : GridContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for song_key in BgmManager.database :
		var song_info = BgmManager.database[song_key]
		var panel = music_panel.instantiate()
		panel.call_deferred("populate",song_info)
		grid.add_child(panel)
	
	
	pass # Replace with function body.

func _enter_tree() -> void:
	get_parent().visibility_changed.connect(_stop_override_parent)
	visibility_changed.connect(_stop_override_self)

func _exit_tree() -> void:
	get_parent().visibility_changed.disconnect(_stop_override_parent)
	visibility_changed.disconnect(_stop_override_self)

func _stop_override_parent() :
	stop_override(get_parent())

func _stop_override_self() :
	stop_override(self)

func stop_override(target : Node) :
	if not target.visible :
			BgmManager.stop_override(BgmManager.TRANSITIONS.CROSSFADE)
