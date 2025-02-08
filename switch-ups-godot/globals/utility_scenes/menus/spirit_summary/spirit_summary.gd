extends Control

@export var label_name : Label
@export var sprite : TextureRect
@export var label_type : RichTextLabel
@export var label_health : Label
@export var label_concrete : Label
@export var label_abstract : Label
@export var label_defense : Label
@export var label_speed : Label
@export var label_luck : Label

func _ready() -> void:
	set_summary_inactive(load("res://monster_systems/spirits/database/placeholder.tres"))

func set_summary_inactive(spirit : ms_spirit) :
	label_name.text = spirit.name
	sprite.texture = spirit.sprite
	label_type.text = "Type : %s" % ms_constants.type_to_bbcode(spirit.type)
	label_health.text = "Health : %s" % spirit.health
	label_concrete.text = "Concrete Power : %s" % spirit.atk_concrete
	label_abstract.text = "Abstract Power : %s" % spirit.atk_abstract
	label_defense.text = "Defense : %s" % spirit.defense
	label_speed.text = "Speed : %s" % spirit.speed
	label_luck.text = "Luck : %s" % spirit.luck

func set_summary_active() :
	printerr("set_summary_active() : Not implemented")
	pass
