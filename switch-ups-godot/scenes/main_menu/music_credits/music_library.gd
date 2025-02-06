extends ScrollContainer

const music_panel = preload("res://scenes/main_menu/music_credits/music_panel.tscn")
@export var grid : GridContainer
@export var min_size : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_columns()
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

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED :
			set_columns()

func set_columns() :
	grid.columns = max(1,floor(float(size.x) / min_size))
