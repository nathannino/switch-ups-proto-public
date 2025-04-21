extends PanelContainer

var key : String
var translated_format_vars : Dictionary
var format_vars : Dictionary

@export var label : RichTextLabel
@export var timer : Timer

var started_dissapear = false

var _can_dissapear : bool = false
var can_dissapear : bool :
	get : return _can_dissapear
	set(value) :
		_can_dissapear = value
		check_dissapear()

var _timeout_reached : bool = false
var timeout_reached : bool :
	get : return _timeout_reached
	set(value) : 
		_timeout_reached = value
		check_dissapear()

func check_dissapear() :
	if started_dissapear :
		return
	
	if timeout_reached and can_dissapear :
		var tween = create_tween()
		tween.tween_property(self,"modulate",Color(1,1,1,0),1)
		tween.tween_callback(func() :
			queue_free.call_deferred()
		)

func _ready() :
	timer.timeout.connect(func() :
		timeout_reached = true
		pass
	)

func set_timeout(_time : float) :
	if _time <= 0 :
		timeout_reached = true
		return
	
	
	timeout_reached = false
	timer.start(_time)
	pass

func set_text(_key : String, _translated_format_vars : Dictionary, _format_vars : Dictionary) :
	key = _key
	translated_format_vars = _translated_format_vars
	format_vars = _format_vars
	
	var _very_translated_format_vars = {}
	for _tr_key in translated_format_vars.keys() :
		var _value = translated_format_vars[_tr_key]
		_very_translated_format_vars[_tr_key] = tr(_value)
	
	label.clear()
	label.append_text(tr(_key).format(_format_vars.merged(_very_translated_format_vars,true)))

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSLATION_CHANGED :
			set_text(key,translated_format_vars,format_vars)
