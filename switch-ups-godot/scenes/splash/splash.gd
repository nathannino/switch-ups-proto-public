extends Control

var main_menu : SceneLoadWrapper
const main_menu_path = "res://scenes/main_menu/main_menu.tscn"

const test_path = "res://scenes/test/test_scene.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("%s : %s - v%s" % [game_info.project_name, game_info.flavor, game_info.version])
	print("Created by Nathan_Nino")
	print("Have fun!")
	#main_menu = SceneLoadWrapper.preinit_scene(main_menu_path)
	main_menu = SceneLoadWrapper.preload_scene(test_path)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	DeferredLoadingManager.change_scene(main_menu)
	pass # Replace with function body.
