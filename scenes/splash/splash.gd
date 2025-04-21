extends Control

var main_menu : SceneLoadWrapper
var transition : SceneLoadWrapper

@export var debug_scene_load : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("%s : %s - protocol verison %s" % [game_info.project_name, game_info.flavor, game_info.version + ("_dev" if game_info.dev else "")])
	print("Created by Nathan_Nino")
	print("Have fun!")
	var key = "main_menu"
	if game_info.dev and (debug_scene_load.length() > 0)	:
		key = debug_scene_load
	main_menu = SceneLoadWrapper.create().from_key(key).background_preload().prepare()
	transition = SceneLoadWrapper.create().as_transition("fade_to_black").prepare()
	#main_menu = SceneLoadWrapper.preload_scene(test_path) #Testing
	
	$BG.bottom_color = Color.BLACK
	$BG.top_color = Color.BLACK
	$BG.vignette_color = Color.BLACK
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_parallel(true)
	tween.tween_property($BG,"bottom_color",Color("#2a2e86"),3)
	tween.tween_property($BG,"top_color",Color("#fa6157"),3)
	tween.tween_property($BG,"vignette_color",Color("#dfd21f"),3)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	DeferredLoadingManager.change_scene(main_menu,transition)
	pass # Replace with function body.
