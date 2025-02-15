extends Control

var main_menu : SceneLoadWrapper
var transition : SceneLoadWrapper

@export var debug_scene_load : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("%s : %s - v%s" % [game_info.project_name, game_info.flavor, game_info.version])
	print("Created by Nathan_Nino")
	print("Have fun!")
	var key = "main_menu"
	if game_info.dev and (debug_scene_load.length() > 0)	:
		key = debug_scene_load
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
