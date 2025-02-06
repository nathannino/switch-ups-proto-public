extends SubViewport

#TODO : Move magic Vector2i to globals
var target_size : Vector2i
#var target_size = Vector2i(3840,2160) # 4k
var target_aspect_ratio : float

func get_parent_viewport() -> Viewport :
	return $"..".get_viewport()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_aspect_ratio = float(target_size.x) / float(target_size.y)
	resize()
	pass # Replace with function body.

func _enter_tree() -> void:
	get_window().size_changed.connect(resize)

func _exit_tree() -> void:
	get_window().size_changed.disconnect(resize)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Ok, really funny, but I want to shout out https://gamemaker.io/en/tutorials/the-basics-of-scaling-the-game-camera for the base this is built on
# Does it show I have a GMS2 background?
# FIXME : If we ever get to a resolution dropdown, this will super mega break
func resize() :
	var window_size = get_window().size
	var window_aspect_ratio = float(window_size.x) / float(window_size.y)
	var width
	var height
	if (window_aspect_ratio < target_aspect_ratio) :
		width = floor(float(target_size.x))
		height = floor(float(target_size.x) / window_aspect_ratio)
	else :
		width = floor(float(target_size.y) * window_aspect_ratio)
		height = floor(float(target_size.y))

	size_2d_override = Vector2i(width,height)
	print("Window resized or scene entered tree! %s's size is now %v" % [name, size_2d_override])
