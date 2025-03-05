extends Node3D

@export var friend_player : Node3D
@export var enemy_player : Node3D
@export var camera : Camera3D

func _ready() -> void:
	friend_player.set_camera(camera)
	friend_player.is_friend = true
	
	enemy_player.set_camera(camera)
	enemy_player.is_friend = false
