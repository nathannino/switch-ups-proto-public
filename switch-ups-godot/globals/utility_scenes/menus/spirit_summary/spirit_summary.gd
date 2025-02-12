extends Control

@export var label_name : RichTextLabel
@export var sprite : TextureRect
@export var label_type : RichTextLabel
@export var label_health : RichTextLabel
@export var label_concrete : RichTextLabel
@export var label_abstract : RichTextLabel
@export var label_defense : RichTextLabel
@export var label_speed : RichTextLabel
@export var label_luck : RichTextLabel
@export var move_holder : Container

var spirit : ms_spirit

func _ready() -> void:
	#set_summary_inactive(load("res://monster_systems/spirits/database/placeholder.tres"))
	pass

func _notification(what: int) -> void:
	match what :
		NOTIFICATION_TRANSLATION_CHANGED:
			if not spirit == null : set_summary_inactive(spirit)
			# TODO Add spirit in active form

func set_summary_inactive(_spirit : ms_spirit) :
	spirit = _spirit
	label_name.text = "[center]{name}[/center]".format({"name":tr(spirit.name)})
	sprite.texture = spirit.sprite
	label_type.text = tr("TR_SUMMARY_TYPE").format({"type":ms_constants.type_to_bbcode(spirit.type)})
	label_health.text = tr("TR_SUMMARY_HEALTH").format({"health":spirit.health})
	label_concrete.text = tr("TR_SUMMARY_CONCRETE").format({"tr":ms_constants.flavor_to_bbcode(ms_constants.ATK_FLAVOR.CONCRETE),"power":spirit.atk_concrete})
	label_abstract.text = tr("TR_SUMMARY_ABSTRACT").format({"tr":ms_constants.flavor_to_bbcode(ms_constants.ATK_FLAVOR.ABSTRACT),"power":spirit.atk_abstract})
	label_defense.text = tr("TR_SUMMARY_DEFENSE").format({"defense":spirit.defense})
	label_speed.text = tr("TR_SUMMARY_SPEED").format({"speed":spirit.speed})
	label_luck.text = tr("TR_SUMMARY_LUCK").format({"luck":spirit.luck})
	move_holder.set_actions(spirit.actions)
	%ActionsLabel.show()

func set_summary_active() :
	printerr("set_summary_active() : Not implemented")
	pass
