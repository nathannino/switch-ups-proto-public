extends Node

@export var error_root : Control

var connected = false
signal connected_ack

@export var client_packed : PackedScene
var client_scene : Node

func connect_signals() :
	client_scene.payload_received.connect(_on_main_client_payload_received)
	client_scene.accepted.connect(_on_main_client_accepted)
	client_scene.disconnected.connect(_on_main_client_disconnected)
	client_scene.error.connect(_on_main_client_error)

func start_client(_host : String, _port : int) -> void :
	if not client_scene == null :
		printerr("Client still exists")
		return
	
	if _host == null or _host == "" :
		_host = "localhost"
	connected = true
	client_scene = client_packed.instantiate()
	add_child(client_scene)
	connect_signals()
	client_scene.start_client(_host,_port)
	return 
	
func send_message_to_server(username : String, message : String) :
	client_scene.send(TcpPayload.new().set_type(TcpPayload.TYPE.SEND_CHAT_MESSAGE).set_content({"username" : username, "message" : message}))

signal disconnected

func _on_main_client_disconnected() -> void:
	DeferredLoadingManager.change_scene(SceneLoadWrapper.create().from_key("main_menu").background_preload().prepare(),
										SceneLoadWrapper.create().as_transition("fade_to_black").prepare())
	disconnected.emit()
	connected = false
	client_scene = null
	pass # Replace with function body.

func disconnect_client() :
	client_scene.regular_disconnect()

func _on_main_client_payload_received(payload: TcpPayload) -> void:
	match payload.get_type():
		_:
			printerr("Unkown type %s" % payload.get_type())
	pass # Replace with function body.


func _on_main_client_accepted() -> void:
	connected_ack.emit()
	pass # Replace with function body.


func _on_main_client_error(reason: String) -> void:
	error_root.show_reason(reason)
	pass # Replace with function body.
