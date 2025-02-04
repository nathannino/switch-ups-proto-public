extends Control

var main_menu : SceneLoadWrapper
const main_menu_path = "res://scenes/main_menu/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu = SceneLoadWrapper.preinit_scene(main_menu_path,{"license":setup_license,"funnies":func() :
		OS.delay_msec(3600)
		return 0
		})
	pass # Replace with function body.

func setup_license() -> String : # This was super slow when I last used it... (https://nathan-nino.itch.io/gmtk2024)
	var license_text = "GODOT LICENSE\n\n" + Engine.get_license_text()

	var components = Engine.get_copyright_info()
	license_text += "\n\n\nTHIRD PARTY LIBRARIES\n\n"
	var license_list = {}
	var regex = RegEx.create_from_string("freetype|enet|mbed")
	for component in components:
		var name = component.name
		license_text += "\n" + name + "\n"
		for part in component.parts:
			license_list[part.license] = true
			license_text += "  License: " + part.license + "\n"
			for line in part.copyright:
				license_text += "  Copyright " + line + "\n"

	var licenses = Engine.get_license_info()
	for k in licenses:
		if license_list.has(k):
			license_text += "\n\n\nLICENSE: " + k + "\n\n" + licenses[k]
	
	return license_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	DeferredLoadingManager.change_scene(main_menu)
	pass # Replace with function body.
