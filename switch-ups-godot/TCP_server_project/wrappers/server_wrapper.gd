extends Node

func start_server(_bind_address : String, _port : int, _server_client_wrapper : PackedScene) -> void :
	$ServerMain.start_server(_bind_address,_port,_server_client_wrapper,global_payload_received)

signal disconnected

var history = []

func get_connections() -> int:
	return $ServerMain.get_child_count()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func global_payload_received(_client : Node, payload : TcpPayload) -> void :
	match payload.get_type() :
		TcpPayload.TYPE.GET_HISTORY :
			_client.send(TcpPayload.new().set_type(TcpPayload.TYPE.SEND_CHAT_HISTORY).set_content(history))
		TcpPayload.TYPE.SEND_CHAT_MESSAGE :
			history.push_back(payload.get_content())
			$ServerMain.send_all(TcpPayload.new().set_type(TcpPayload.TYPE.SEND_CHAT_MESSAGE).set_content(payload.get_content()))
		_ :
			printerr("Unkown global type : %s" % payload.get_type())
	pass
