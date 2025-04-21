extends Node

var config = ConfigFile.new()
const FILEPATH = "user://user.cfg"
var firstrun = true
var camera_static = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (not FileAccess.file_exists(FILEPATH)) or game_info.dev :
		firstrun = true
		config.set_value("sounds","primary",1.0)
		config.set_value("sounds","BGM",1.0)
		config.set_value("sounds","effects",1.0)
		
		config.set_value("accessibility","disable_camera_movement",false)
		config.set_value("accessibility","ui_scale",1.0)
		
		config.set_value("game","language",null)
		
		config.set_value("graphics","fullscreen",false)
		
		config.save(FILEPATH)
	else :
		firstrun = false
		config.load(FILEPATH)
	
	apply_config()
	get_window().min_size = Vector2(640,360)

func apply_config() -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"),config.get_value("sounds","primary",1.0))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("BGM"),config.get_value("sounds","BGM",1.0))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Effects"),config.get_value("sounds","effects",1.0))
	
	camera_static = config.get_value("accessibility","disable_camera_movement",false)
	get_window().content_scale_factor = config.get_value("accessibility","ui_scale",1.0)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if config.get_value("graphics","fullscreen",false) else DisplayServer.WINDOW_MODE_WINDOWED)
	
	if config.has_section_key("game","language") :
		TranslationServer.set_locale(config.get_value("game","language","en"))

func set_language(shorthand : String) :
	config.set_value("game","language",shorthand)

func save_values() -> void:
	config.set_value("sounds","primary",AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master")))
	config.set_value("sounds","BGM",AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("BGM")))
	config.set_value("sounds","effects",AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Effects")))
		
	config.set_value("accessibility","disable_camera_movement",camera_static)
	config.set_value("accessibility","ui_scale",get_window().content_scale_factor)
	
	config.set_value("graphics","fullscreen",(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN))
	
	firstrun = false
	config.save(FILEPATH)
	pass
