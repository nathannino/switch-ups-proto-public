extends Control

@export var scrollbar : ScrollBar
@export var button_template : PackedScene
@export var button_root : VBoxContainer

var is_ready = false
var spirits_array = []

func _ready() -> void:
	is_ready = true
	order_spirits()
	recalculate_lazyload()
	scrollbar.value_changed.connect(recalculate_lazyload)
	pass

func _exit_tree() -> void:
	scrollbar.value_changed.disconnect(recalculate_lazyload)

func order_spirits() : #TODO : Turn into that pattern. You know the one ;)
	var old_spirit_dict = SpiritDictionary.spirits
	var ordering_array = old_spirit_dict.values().duplicate()
	ordering_array.sort_custom(func (a,b) :
		return a.name.naturalnocasecmp_to(b) < 0
	)
	scrollbar.max_value = ordering_array.size()
	scrollbar.value = 0
	spirits_array = ordering_array

func recalculate_lazyload() :
	var child_id = 0
	var page_amount = 0
	for child in button_root.get_children() :
		printerr("Not implemented, will probably delete tbh")
	pass

func _notification(what: int) -> void:
	match what :
		NOTIFICATION_RESIZED :
			if is_ready :
				recalculate_lazyload()
