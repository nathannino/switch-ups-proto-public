extends Object
class_name global_func

# https://docs.godotengine.org/en/stable/tutorials/math/beziers_and_curves.html#quadratic-bezier
static func quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	
	var r = q0.lerp(q1, t)
	return r
