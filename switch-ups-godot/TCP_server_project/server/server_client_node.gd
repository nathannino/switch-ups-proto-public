extends Node

var peer : StreamPeerTCP;

func peer_ready(_peer : StreamPeerTCP) -> void:
	peer = _peer;
	print("%s connected to server" % peer)
	var payload = TcpPayload.new().set_type(TcpPayload.TYPE.ASK_VER).set_content(TcpPayload.PROTOCOL_VER)
	send(payload)

func peer_refused(_peer : StreamPeerTCP) -> void:
	peer = _peer
	print("%s was refused" % peer)
	send(TcpPayload.new().set_type(TcpPayload.TYPE.ERR_DISCONNECT).set_content("full"))
	queue_free() # Not sending disconnected, as this shouldn't even be considered connected

# TODO Include check to see if connected or not I guess
func send(_payload : TcpPayload) :
	peer.put_utf8_string(_payload.get_sent_json())

signal payload_received(payload : TcpPayload)
signal disconnected

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if peer == null :
		return
	var can_poll = peer.poll()
	if not can_poll == 0 :
		printerr("Polling failed %s" % can_poll)
		queue_free() # TODO : Actually show an error message
	var _status = peer.get_status()
	match _status :
		peer.STATUS_NONE :
			print("Server not connected to client %s, acting as disconnected" % peer)
			disconnected.emit()
			queue_free()
		peer.STATUS_ERROR :
			printerr("%s had an error" % peer)
			send(TcpPayload.new().set_type(TcpPayload.TYPE.ERR_DISCONNECT).set_content("Internal Server Error")) # We keep trying
			disconnected.emit()
			queue_free() # TODO : Actually show an error message
		peer.STATUS_CONNECTED : 
			var _available_bytes: int = peer.get_available_bytes()
			if _available_bytes > 0 :
				var _string = peer.get_utf8_string()
				var payload = TcpPayload.new().parse_json(_string)
				match payload.get_type() :
					TcpPayload.TYPE.ASK_VER:
						if not payload.get_content() == TcpPayload.PROTOCOL_VER :
							send(TcpPayload.new().set_type(TcpPayload.TYPE.ERR_DISCONNECT).set_content("Mismatched Protocol_Ver"))
						else :
							send(TcpPayload.new().set_type(TcpPayload.TYPE.ASK_VER_ACCEPTED))
						return
					TcpPayload.TYPE.ERR_DISCONNECT :
						peer.disconnect_from_host()
						disconnected.emit()
						printerr("Disconnected from client : %s" % payload.get_content())
						queue_free()
						return
					TcpPayload.TYPE.SEND_MESSAGE :
						print("Debug message received from peer %s" % peer)
						print(payload.get_content())
						return
					_ :
						payload_received.emit(payload)
						return
		pass
