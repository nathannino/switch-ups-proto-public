extends Node

var username : String

const chatbox = preload("res://TCP_server_project/client_ui.tscn")
var ui_instance : Control

func start_client(_host : String, _port : int, _username : String, ui_node : Control) -> void :
	if _username == null or _username == "" :
		printerr("Username required")
		return
	if _host == null or _host == "" :
		_host = "localhost"
	username = _username
	ui_instance = chatbox.instantiate()
	ui_instance.name = _username
	ui_instance.send_message.connect(send_message_to_server)
	ui_node.add_child(ui_instance)
	$MainClient.start_client(_host,_port)
	return 
	
func send_message_to_server(username : String, message : String) :
	$MainClient.send(TcpPayload.new().set_type(TcpPayload.TYPE.SEND_CHAT_MESSAGE).set_content({"username" : username, "message" : message}))

signal disconnected

func _on_main_client_disconnected() -> void:
	if not ui_instance == null :
		ui_instance.queue_free()
	disconnected.emit()
	queue_free()
	pass # Replace with function body.


func _on_main_client_payload_received(payload: TcpPayload) -> void:
	match payload.get_type():
		TcpPayload.TYPE.SEND_CHAT_HISTORY:
			for chat in payload.get_content() :
				ui_instance.add_message(chat["username"],chat["message"])
		TcpPayload.TYPE.SEND_CHAT_MESSAGE:
			var chat = payload.get_content()
			ui_instance.add_message(chat["username"],chat["message"])
		_:
			printerr("Unkown type %s" % payload.get_type())
	pass # Replace with function body.


func _on_main_client_accepted() -> void:
	$MainClient.send(TcpPayload.new().set_type(TcpPayload.TYPE.GET_HISTORY))
	pass # Replace with function body.
