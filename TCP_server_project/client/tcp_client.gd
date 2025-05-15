extends Node

const HOST = "localhost";
const PORT = 5029;

var peer : StreamPeerTCP

# Called when the node enters the scene tree for the first time.
func start_client(_host : String, _port : int) -> void :
	peer = StreamPeerTCP.new()
	if not peer.connect_to_host(_host,_port) == OK :
		printerr("Connection failed (I don't know how to reach this)")
		error.emit("ERR_CLIENT_CANNOT_CONNECT")
		disconnected.emit()
		queue_free()
		return
	print("Connected to server")

# TODO Include check to see if connected or not I guess
func send(_payload : TcpPayload) :
	peer.put_utf8_string(_payload.get_sent_json())

signal payload_received(payload : TcpPayload)
signal accepted
signal disconnected
signal error(reason : String)

func regular_disconnect() :
	peer.disconnect_from_host()
	disconnected.emit()
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if peer == null :
		return
	var can_poll = peer.poll()
	if not can_poll == 0 :
		printerr("Polling failed %s" % can_poll)
		match can_poll :
			ERR_CONNECTION_ERROR :
				error.emit("ERR_CLIENT_CANNOT_CONNECT")
				disconnected.emit()
				queue_free()
				return
	match peer.get_status() :
		peer.STATUS_NONE :
			print("Client not connected to server %s, acting as disconnected" % peer)
			disconnected.emit()
			error.emit("ERR_LOST_CONNECTION")
			queue_free()
		peer.STATUS_ERROR :
			printerr("%s had an error" % peer)
			send(TcpPayload.new().set_type(TcpPayload.TYPE.ERR_DISCONNECT).set_content("Internal Client Error")) # We keep trying
			disconnected.emit()
			error.emit("ERR_INTERNAL_CLIENT")
			queue_free() # TODO : Actually show an error message
		peer.STATUS_CONNECTED :
			var _available_bytes: int = peer.get_available_bytes()
			if _available_bytes > 0 :
				var _string = peer.get_utf8_string()
				if game_info.show_network_messages :
					print("[Client received message] : ")
					print(_string)
				var payload = TcpPayload.new().parse_json(_string)
				match payload.get_type() :
					TcpPayload.TYPE.ASK_VER:
						send(TcpPayload.new().set_type(TcpPayload.TYPE.ASK_VER).set_content(TcpPayload.PROTOCOL_VER))
						return
					TcpPayload.TYPE.ERR_DISCONNECT :
						peer.disconnect_from_host()
						disconnected.emit()
						printerr("Disconnected from server : %s" % payload.get_content())
						error.emit(payload.get_content())
						queue_free()
						return
					TcpPayload.TYPE.ASK_VER_ACCEPTED :
						accepted.emit()
						return
					TcpPayload.TYPE.SEND_MESSAGE :
						print("Debug message received from peer %s" % peer)
						print(payload.get_content())
					_ :
						payload_received.emit(payload)
	pass
