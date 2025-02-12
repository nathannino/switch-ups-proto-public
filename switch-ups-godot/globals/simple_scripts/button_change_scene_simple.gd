extends Button

@export var key : String
@export var transition_key = "wipe_rect"
var target : SceneLoadWrapper
var transition : SceneLoadWrapper

func _ready() -> void:
	pressed.connect(change_scene)
	target = SceneLoadWrapper.create().background_preload().from_key(key).prepare()
	#transition = SceneLoadWrapper.create().as_transition("none").prepare()
	transition = SceneLoadWrapper.create().as_transition("wipe_rect").prepare()

func change_scene() :
	BgmManager.stop_override(BgmManager.TRANSITIONS.FADE_OUT_IN)
	DeferredLoadingManager.change_scene(target,transition)
