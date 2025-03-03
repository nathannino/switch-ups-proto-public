extends Panel

@export var line : Texture2D
@export var logs : VBoxContainer

var turn = 0

var current_label : RichTextLabel = null
var turn_history = []
func new_turn() :
	turn += 1
	if current_label is RichTextLabel :
		current_label.newline()
	#logs.append_text("[img={width:100%,height:1}]" + line + "[/img]")
	var texture_rect = TextureRect.new()
	texture_rect.texture = line
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	texture_rect.custom_minimum_size = Vector2(0,5)
	logs.add_child(texture_rect)
	
	current_label = RichTextLabel.new()
	current_label.scroll_active = false
	current_label.fit_content = true
	current_label.bbcode_enabled = true
	logs.add_child(current_label)
	turn_history.push_back([])
	
	add_log("TR_BTLLOG_STARTTURN",{"turn":turn})
	pass

func _add_log(key, format_vars, label) :
	label.newline()
	label.append_text(tr(key).format(format_vars))

func add_log(key : String, format_vars : Dictionary = {},translated_format_vars : Dictionary = {}) :
	var _very_translated_format_vars = {}
	for _key in translated_format_vars.keys() :
		var _value = translated_format_vars[_key]
		_very_translated_format_vars[_key] = tr(_value)
	turn_history[-1].push_back([key,format_vars,translated_format_vars])
	_add_log(key,format_vars.merged(_very_translated_format_vars,true),current_label)

func clear() :
	turn_history = []
	for child in logs.get_children() :
		child.queue_free()

func _notification(what: int) -> void:
	match what :
		NOTIFICATION_TRANSLATION_CHANGED :
			var index = 0
			for child in logs.get_children() :
				if child is RichTextLabel :
					child.clear()
					var _current_turn = turn_history[index]
					for _current_action in _current_turn :
						var _very_translated_format_vars = {}
						for _key in _current_action[2].keys() :
							var _value = _current_action[2][_key]
							_very_translated_format_vars[_key] = tr(_value)
						_add_log(_current_action[0],_current_action[1].merged(_very_translated_format_vars),child)
					index += 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("options") :
		hide()
