extends Panel

@export var StatusRect : TextureRect
@export var StatusLabel : Label

enum status_list {
	UNKNOWN = 0,
	CONCRETE = 1,
	ABSTRACT = 2,
	DEFENSE = 3,
	SPEED = 4,
	LUCK = 5,
	PRIORITY = 6
}

var status = int(status_list.UNKNOWN)
var saved_status = int(status_list.UNKNOWN)

var icon_list = [
	preload("uid://masa1osx0s86"), # Unknown
	preload("uid://beunnlf5g35ur"), # Concrete
	preload("uid://b1pawseunm44f"), # Abstract
	preload("uid://dyfoxvv5qtgb6"), # Defense
	preload("uid://c72hw1setcvp2"), # Speed
	preload("uid://ckd21i66e3fyi"), # Luck
	preload("uid://ell7purhp040"), # Priority
]

func set_status(status_type, amount) :
	saved_status = status_type
	if status_type < icon_list.size() :
		status = status_type
	else :
		status = int(status_list.UNKNOWN)
	StatusRect.texture = icon_list[status]
	
	if amount == 0 :
		queue_free()
	
	if amount > 0 :
		StatusLabel.text = "+" + str(amount)
	else :
		StatusLabel.text = str(amount)
