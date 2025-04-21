extends Node3D

@export var ball : MeshInstance3D
@export var particles : GPUParticles3D

var shader : ShaderMaterial
const DURATION = 1.5

signal animation_done
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	particles.emitting = false
	ball.visible = false
	var mat = ball.get_active_material(0)
	if mat is ShaderMaterial :
		shader = mat
	else :
		printerr("Material isn't a shader why =(((")

func play() :
	shader.set_shader_parameter("progress",1)
	ball.visible = true
	var tween = create_tween()
	tween.tween_callback(func() : particles.emitting = true)
	tween.tween_method(func(_value) :
		shader.set_shader_parameter("progress",_value)
	,0.0,1.0,DURATION)
	tween.parallel().tween_method(func(_value) :
		if _value > 0.7 :
			particles.emitting = false
	,0.0,1.0,DURATION)
	tween.tween_interval(0.2)
	tween.tween_callback(func() :
		particles.emitting = false
		ball.visible = false
		animation_done.emit.call_deferred()
	)
