extends Control

var main_menu : SceneLoadWrapper
var transition : SceneLoadWrapper

@export var debug_scene_load : String
@export var hack_notimer : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not hack_notimer :
		print("%s : %s - protocol verison %s" % [game_info.project_name, game_info.flavor, game_info.version + ("_dev" if game_info.dev else "")])
		print("Created by Nathan_Nino")
		print("Have fun!")

		var key = "main_menu"
		if game_info.dev and (debug_scene_load.length() > 0)	:
			key = debug_scene_load
		main_menu = SceneLoadWrapper.create().from_key(key).background_preload().prepare()
		transition = SceneLoadWrapper.create().as_transition("fade_to_black").prepare()
	
	var bottom_color = $BG.bottom_color
	var top_color = $BG.top_color
	var vignette_color = $BG.vignette_color
	$BG.bottom_color = Color.BLACK
	$BG.top_color = Color.BLACK
	$BG.vignette_color = Color.BLACK
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	#tween.set_trans(Tween.TRANS_SINE)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(true)
	tween.tween_property($BG,"bottom_color",bottom_color,3)
	tween.tween_property($BG,"top_color",top_color,3)
	tween.tween_property($BG,"vignette_color",vignette_color,3)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$fade_proc.hide()
	pass


func _on_timer_timeout() -> void:
	if hack_notimer :
		return
	DeferredLoadingManager.change_scene(main_menu,transition)
	pass # Replace with function body.
