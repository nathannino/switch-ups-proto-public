extends ScrollContainer

const music_panel = preload("res://scenes/main_menu/music_credits/music_panel.tscn")
@export var grid : Container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for song_key in BgmManager.database :
		var song_info = BgmManager.database[song_key]
		var panel = music_panel.instantiate()
		panel.call_deferred("populate",song_info)
		grid.add_child(panel)
	
	visibility_changed.connect(func() :
		if not visible :
			BgmManager.stop_override(BgmManager.TRANSITIONS.CROSSFADE)
	)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
