extends Control

var main_menu : SceneLoadWrapper
var transition : SceneLoadWrapper

const debug_room = "tcp_port"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("%s : %s - v%s" % [game_info.project_name, game_info.flavor, game_info.version])
	print("Created by Nathan_Nino")
	print("Have fun!")
	var key = "main_menu"
	if (not debug_room == null) or (debug_room.length() > 0)	:
		key = debug_room
	main_menu = SceneLoadWrapper.create().from_key(key).background_preload().prepare()
	transition = SceneLoadWrapper.create().as_transition("fade_to_black").prepare()
	#main_menu = SceneLoadWrapper.preload_scene(test_path) #Testing
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	DeferredLoadingManager.change_scene(main_menu,transition)
	pass # Replace with function body.
