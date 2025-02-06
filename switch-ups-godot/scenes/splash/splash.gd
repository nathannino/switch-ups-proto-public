extends Control

var main_menu : SceneLoadWrapper
const main_menu_path = "res://scenes/main_menu/main_menu.tscn"

const test_path = "res://scenes/test/test_scene.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("%s : %s - v%s" % [game_info.project_name, game_info.flavor, game_info.version])
	print("Created by Nathan_Nino")
	print("Have fun!")
	main_menu = SceneLoadWrapper.preinit_scene(test_path,{"license":setup_license,"funnies":func() :
		OS.delay_msec(1) #TODO : Retirer ce bout de code lol
		return 0
		})
	pass # Replace with function body.

func setup_license() -> String : # This was super slow when I last used it... (https://nathan-nino.itch.io/gmtk2024)
	var license_text = "GODOT LICENSE\n\n" + Engine.get_license_text()

	
	
	return license_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	DeferredLoadingManager.change_scene(main_menu)
	pass # Replace with function body.
