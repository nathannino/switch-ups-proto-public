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
@export var label_priority : RichTextLabel
@export var move_holder : Container

@export var spirit_label : Label
@export var spirit_button : Control

var spirit : ms_spirit
var spirit_active : ms_spirit_active

func _ready() -> void:
	#set_summary_inactive(load("res://monster_systems/spirits/database/placeholder.tres"))
	pass

func _notification(what: int) -> void:
	match what :
		NOTIFICATION_TRANSLATION_CHANGED:
			reload_content()

func reload_content() :
	if spirit_active == null and not spirit == null : set_summary_inactive(spirit)
	elif not spirit_active == null : set_summary_active(spirit_active)
	else : set_empty()

func set_empty() :
	spirit = null
	spirit_active = null
	label_name.text = ""
	sprite.texture = null
	label_type.text = ""
	label_health.text = ""
	label_concrete.text = ""
	label_abstract.text = ""
	label_defense.text = ""
	label_speed.text = ""
	label_luck.text = ""
	move_holder.set_actions([])
	%ActionsLabel.hide()
	spirit_label.hide()
	spirit_button.hide()
	spirit_button.reset()

func set_summary_inactive(_spirit : ms_spirit) :
	spirit = _spirit
	spirit_active = null
	label_name.text = "[center]{name}[/center]".format({"name":tr(spirit.name)})
	sprite.texture = spirit.sprite
	label_type.text = tr("TR_SUMMARY_TYPE").format({"type":ms_constants.type_to_bbcode(spirit.type)})
	label_health.text = tr("TR_SUMMARY_HEALTH").format({"health":spirit.health})
	label_concrete.text = tr("TR_SUMMARY_CONCRETE").format({"tr":ms_constants.flavor_to_bbcode(ms_constants.ATK_FLAVOR.CONCRETE),"power":spirit.atk_concrete})
	label_abstract.text = tr("TR_SUMMARY_ABSTRACT").format({"tr":ms_constants.flavor_to_bbcode(ms_constants.ATK_FLAVOR.ABSTRACT),"power":spirit.atk_abstract})
	label_defense.text = tr("TR_SUMMARY_DEFENSE").format({"defense":spirit.defense})
	label_speed.text = tr("TR_SUMMARY_SPEED").format({"speed":spirit.speed})
	label_luck.text = tr("TR_SUMMARY_LUCK").format({"luck":spirit.luck})
	label_priority.hide()
	move_holder.set_actions(spirit.actions)
	%ActionsLabel.show()
	spirit_button.hide()
	spirit_label.hide()
	spirit_button.reset()

func add_bonus(key : String, _format : Dictionary, bonus : int, bonus_multi : float) :
	var addition = "" if bonus == 0 else " (+%s)" % (bonus * bonus_multi) if bonus > 0 else " (-%s)" % (abs(bonus * bonus_multi))
	return tr(key).format(_format) + addition

func set_summary_active(_spirit : ms_spirit_active) :
	spirit_active = _spirit
	spirit = SpiritDictionary.spirits[spirit_active.key]
	label_name.text = "[center]{name}[/center]".format({"name":tr(spirit.name)})
	sprite.texture = spirit.sprite
	label_type.text = tr("TR_SUMMARY_TYPE").format({"type":ms_constants.type_to_bbcode(spirit.type)})
	label_health.text = tr("HP : {curr}/{max}").format({"curr":spirit_active.current_hp,"max":spirit.health})
	label_concrete.text = add_bonus("TR_SUMMARY_CONCRETE",{"tr":ms_constants.flavor_to_bbcode(ms_constants.ATK_FLAVOR.CONCRETE),"power":spirit.atk_concrete},spirit_active.atk_concrete_change,spirit_active.ATK_CONCRETE_CHANGE_MULTI)
	label_abstract.text = add_bonus("TR_SUMMARY_ABSTRACT",{"tr":ms_constants.flavor_to_bbcode(ms_constants.ATK_FLAVOR.ABSTRACT),"power":spirit.atk_abstract},spirit_active.atk_abstract_change,spirit_active.ATK_ABSTRACT_CHANGE_MULTI)
	label_defense.text = add_bonus("TR_SUMMARY_DEFENSE",{"defense":spirit.defense},spirit_active.defense_change,spirit_active.DEFENSE_CHANGE_MULTI)
	label_speed.text = add_bonus("TR_SUMMARY_SPEED",{"speed":spirit.speed},spirit_active.speed_change,spirit_active.DEFENSE_CHANGE_MULTI)
	label_luck.text = add_bonus("TR_SUMMARY_LUCK",{"luck":spirit.luck},spirit_active.luck_change,spirit_active.LUCK_CHANGE_MULTI)
	move_holder.set_actions(spirit_active.get_actions_combined_converted())
	%ActionsLabel.show()
	spirit_label.show()
	spirit_button.show()
	
	if (spirit_active.priority_change != 0) :
		label_priority.show()
		label_priority.text = tr("TR_SUMMARY_PRIORITY").format({"lv":spirit_active.priority_change})
	else :
		label_priority.hide()
	
	if not _spirit.key_equip == "" :
		spirit_button.set_spirit_inactive(SpiritDictionary.spirits[spirit_active.key_equip])
	else : 
		spirit_button.reset()
	pass

signal move_selected(index : int, action : ms_action)
signal requested_equip_change

func _on_move_holder_move_selected(index: int, action: ms_action) -> void:
	move_selected.emit(index,action)


func _on_monster_button_pressed_option(index: int) -> void:
	requested_equip_change.emit()
	pass # Replace with function body.
