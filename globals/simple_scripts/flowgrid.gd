extends GridContainer

@export var min_size : float
@export var max_columns : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#_set_columns()

func _set_columns() :
	var columns_fit = max(1,floor(float(size.x) / min_size))
	if max_columns < 1 :
		columns = columns_fit
	else :
		columns = min(columns_fit,max_columns)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED :
			_set_columns()
