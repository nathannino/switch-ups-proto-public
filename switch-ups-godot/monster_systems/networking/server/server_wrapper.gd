extends Node

@export var server_client_wrapper : PackedScene
@export var error_root : Control

const MAX_PLAYERS = 2

func start_server(_bind_address : String, _port : int) -> bool :
	match $ServerMain.start_server(_bind_address,_port,server_client_wrapper,global_payload_received) :
		ERR_ALREADY_IN_USE :
			error_root.show_reason("ERR_PORT_IN_USE")
			return false
		_:
			return true

func close_server() :
	$ServerMain.close_server()

func change_scene_all(scene_key : String, transition_key : String) :
	$ServerMain.send_all(TcpPayload.new().set_type(TcpPayload.TYPE.CHANGE_SCENE).set_content({"scene_key":scene_key,"transition_key":transition_key}))

signal disconnected

func get_connections() -> int:
	return $ServerMain.get_child_count()

func set_state_teambuilding() :
	for child in $ServerMain.get_children() :
		child.state_teambuilding()

func set_state_battle_start() :
	for child in $ServerMain.get_children() :
		child.state_startbattle()

func global_payload_received(_client : Node, payload : TcpPayload) -> void :
	match payload.get_type() :
		TcpPayload.TYPE.TEAMBUILD_SET_READY_STATE :
			var readys = 0
			for child in $ServerMain.get_children() :
				if child.teambuilding_is_ready :
					readys += 1
			if readys >= MAX_PLAYERS :
				$ServerMain.send_all(TcpPayload.new().set_type(TcpPayload.TYPE.TEAMBUILD_REQUEST_TEAM))
		TcpPayload.TYPE.TEAMBUILD_SEND_TEAM :
			var readys = 0
			for child in $ServerMain.get_children() :
				if child.teambuilding_received_team :
					readys += 1
			if readys >= MAX_PLAYERS :
				set_state_battle_start()
		_ :
			printerr("Unkown global type : %s" % payload.get_type())
	pass


func _on_server_main_client_disconnected() -> void:
	# Let's keep it simple and just send everyone back
	for child in $ServerMain.get_children() :
		if child.in_battle : # Check to not lose info, since we don't sync teams in teambuild state
			child.state_teambuilding()
	pass # Replace with function body.
