extends Object

class_name window_constants

const TARGET_RESOLUTION = Vector2(1920, 1080)
const TARGET_AR = TARGET_RESOLUTION.x / TARGET_RESOLUTION.y

enum WINDOW_ORI {
	WIDTH,
	HEIGHT
}

static func get_orientation(_size : Vector2) :
	var current_ar = _size.x / _size.y
	if current_ar > TARGET_AR :
		return WINDOW_ORI.WIDTH
	else :
		return WINDOW_ORI.HEIGHT
