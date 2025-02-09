extends Button

@export var key : String
var target : SceneLoadWrapper

func _ready() -> void:
	pressed.connect(change_scene)
	target = SceneLoadWrapper.create().background_preload().from_key(key).prepare()

func change_scene() :
	DeferredLoadingManager.change_scene(target)
