extends Node

@export var server_client_wrapper : PackedScene

func start_server(_bind_address : String, _port : int) -> void :
	$ServerMain.start_server(_bind_address,_port,server_client_wrapper,global_payload_received)

signal disconnected

func get_connections() -> int:
	return $ServerMain.get_child_count()

func global_payload_received(_client : Node, payload : TcpPayload) -> void :
	match payload.get_type() :
		_ :
			printerr("Unkown global type : %s" % payload.get_type())
	pass
