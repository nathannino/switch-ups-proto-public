extends Node

const BIND_ADRESS = "*";
const PORT = 25565;

var server : TCPServer

var client : PackedScene
var client_signal : Callable

func start_server(_bind_address : String, _port : int, _server_client_wrapper : PackedScene, global_signal_emitable : Callable) -> Error :
	server = TCPServer.new();
	client = _server_client_wrapper
	client_signal = global_signal_emitable
	var response = server.listen(_port, _bind_address);
	if not response == 0 :
		printerr("Server failed to start : %s" % response)
	return response

func close_server() :
	if server == null :
		return
	
	for child in get_children() :
		child.disconnect_from_server()
	server.stop()
	server = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if server == null :
		return
	if server.is_listening() and server.is_connection_available() :
		print("connection available")
		var client_peer = server.take_connection();
		var client_scene = client.instantiate();
		client_scene.global_payload_received.connect(client_signal)
		add_child(client_scene)
		client_scene.peer_ready(client_peer);
	pass
	
func send_all(payload : TcpPayload) -> void :
	var children = get_children()
	for n in children :
		n.send(payload)
