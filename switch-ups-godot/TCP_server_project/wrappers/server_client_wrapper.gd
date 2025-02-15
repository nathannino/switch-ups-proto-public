extends Node

func peer_ready(_peer : StreamPeerTCP) -> void:
	$ServerClientNode.peer_ready(_peer)

signal disconnected

signal global_payload_received(_self : Node, _payload : TcpPayload)

func _on_server_client_node_payload_received(payload: TcpPayload) -> void:
	match payload.get_type() :
		TcpPayload.TYPE.GET_HISTORY, TcpPayload.TYPE.SEND_CHAT_MESSAGE :
			global_payload_received.emit(self,payload)
		_:
			printerr("Unkown type %s" % payload.get_type())
	pass # Replace with function body.


func _on_server_client_node_disconnected() -> void:
	disconnected.emit()
	queue_free()
	pass # Replace with function body.
	
func send(_payload : TcpPayload) -> void :
	$ServerClientNode.send(_payload)
