extends Control

var initial_position = 0
var initial_position_bg = 0
var value = 0

@export var show_duration : float
@export var hide_duration : float

@onready var clip = $ProgressBarClip
@onready var bar = $ProgressBarClip/ProgressBarValue
@onready var bg = $ProgressBarClip/ProgressBarBg
@onready var clip_timer = $clip_timer

const bg_trans = Tween.TRANS_CUBIC
const bg_ease = Tween.EASE_IN_OUT
const bar_trans = Tween.TRANS_CUBIC
const bar_ease = Tween.EASE_IN_OUT
const clip_trans = Tween.TRANS_LINEAR
const clip_ease = Tween.EASE_OUT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clip.value = 0
	bar.value = 0
	bg.value = 100
	pass # Replace with function body.

var is_showing = false
var showing_time = 0
func show_bar() :
	is_showing = true
	reset_hiding()
	clip.value = 0
	clip_timer.stop()
	is_hiding_timer = false
	clip.fill_mode = TextureProgressBar.FILL_RIGHT_TO_LEFT
	pass

func bar_is_hiding() -> bool :
	return is_hiding or is_hiding_timer

var is_hiding = false
var is_hiding_timer = false
var hiding_time = 0
func reset_hiding() :
	is_hiding = false
	hiding_time = 0

func hide_bar() :
	reset_hiding()
	is_hiding_timer = true
	clip_timer.start()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_showing and is_hiding and clip.value == 0 :
		is_showing = false
		clip.value = 0
		bar.value = 0
		bg.value = 0
		showing_time = 0
	
	if is_hiding and is_showing :
		hiding_time += delta
		clip.value = Tween.interpolate_value(100,-100,hiding_time,hide_duration,clip_trans,clip_ease)
	
	if is_showing :
		showing_time += delta
		bar.value = value
		if not is_hiding :
			clip.value = Tween.interpolate_value(0,100,clamp(showing_time,0,show_duration),show_duration,bg_trans,bg_ease)
	pass


func _on_clip_timer_timeout() -> void:
	is_hiding = true
	is_hiding_timer = false
	clip.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
	
	pass # Replace with function body.
