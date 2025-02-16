extends Node

@export var server_client_wrapper : PackedScene
@export var error_root : Control

func start_server(_bind_address : String, _port : int) -> bool :
	match $ServerMain.start_server(_bind_address,_port,server_client_wrapper,global_payload_received) :
		ERR_ALREADY_IN_USE :
			error_root.show_reason("TR_MSG_PORT_IN_USE")
			return false
		_:
			return true
	

signal disconnected

func get_connections() -> int:
	return $ServerMain.get_child_count()

func global_payload_received(_client : Node, payload : TcpPayload) -> void :
	match payload.get_type() :
		_ :
			printerr("Unkown global type : %s" % payload.get_type())
	pass
