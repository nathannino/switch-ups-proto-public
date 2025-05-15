
extends Node

var peer : StreamPeerTCP;
var verified = false

func peer_ready(_peer : StreamPeerTCP) -> void:
	peer = _peer;
	print("%s connected to server" % peer)
	var payload = TcpPayload.new().set_type(TcpPayload.TYPE.ASK_VER).set_content(TcpPayload.PROTOCOL_VER)
	send(payload)

func peer_refused(_peer : StreamPeerTCP) -> void:
	peer = _peer
	print("%s was refused" % peer)
	disconnect_from_server(false,"ERR_SERVER_FULL")

func disconnect_from_server(_emit_signal = true, reason = "ERR_SERVER_GENERIC") :
	send(TcpPayload.new().set_type(TcpPayload.TYPE.ERR_DISCONNECT).set_content(reason))
	peer.disconnect_from_host()
	if _emit_signal : disconnected.emit()
	queue_free()

# TODO Include check to see if connected or not I guess
func send(_payload : TcpPayload) :
	peer.put_utf8_string(_payload.get_sent_json())

signal payload_received(payload : TcpPayload)
signal disconnected
signal accepted

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
			disconnect_from_server(true,"ERR_SERVER_ERROR")
		peer.STATUS_CONNECTED : 
			var _available_bytes: int = peer.get_available_bytes()
			if _available_bytes > 0 :
				var _string = peer.get_utf8_string()
				if game_info.show_network_messages :
					print("[Server received message] : ")
					print(_string)
				var payload = TcpPayload.new().parse_json(_string)
				match payload.get_type() :
					TcpPayload.TYPE.ASK_VER:
						if not payload.get_content() == TcpPayload.PROTOCOL_VER :
							disconnect_from_server(true,"ERR_SERVER_PROTOCOLVER")
						else :
							send(TcpPayload.new().set_type(TcpPayload.TYPE.ASK_VER_ACCEPTED))
							verified = true
							accepted.emit()
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
						if verified :
							payload_received.emit(payload)
							return
		pass


func _on_timer_timeout() -> void:
	if not verified :
		disconnect_from_server(true,"ERR_LOST_CONNECTION")
		pass
	pass # Replace with function body.
