extends MeshInstance3D

@export var animation : AnimationPlayer

signal animation_done

const CONCRETE = "concrete_attack"
const ABSTRACT = "abstract_attack" # TODO : implement this

func _ready() -> void:
	animation.animation_finished.connect(func(_value) :
		animation_done.emit()
	)

func set_color(color : Color) :
	var mat = get_active_material(0)
	if mat is ShaderMaterial :
		mat.set_shader_parameter("color",color)

func play_concrete() :
	animation.stop()
	animation.play(CONCRETE)

func play_abstract() :
	animation.stop()
	animation.play(ABSTRACT)
