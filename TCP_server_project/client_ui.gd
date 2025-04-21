extends Control


var scrollbar : VScrollBar

func _ready() -> void:
	scrollbar = $VBoxContainer/ScrollContainer.get_v_scroll_bar()
	pass

func add_message(_username : String, _message : String) -> void :
	var chat_username = Label.new()
	chat_username.text = _username
	chat_username.add_theme_constant_override("outline_size",10)
	chat_username.set("theme_override_colors/font_color",Color.YELLOW)
	chat_username.size_flags_vertical = Control.SIZE_EXPAND
	var chat_message = Label.new()
	chat_message.text = _message
	var chat_hold = VBoxContainer.new()
	chat_hold.add_child(chat_username)
	chat_hold.add_child(chat_message)
	$VBoxContainer/ScrollContainer/MarginContainer/Texting.add_child(chat_hold)
	
	await get_tree().process_frame
	scrollbar.value = scrollbar.max_value
	pass

signal send_message(username : String, message : String)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_send_button_pressed() -> void:
	send_message.emit(name,$VBoxContainer/HBoxContainer/TextEdit.get_text())
	$VBoxContainer/HBoxContainer/TextEdit.clear()
	pass # Replace with function body.
