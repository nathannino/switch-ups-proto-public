extends Node
func start_client(_host : String, _port : int) -> void :
	if _host == null or _host == "" :
		_host = "localhost"
	$MainClient.start_client(_host,_port)
	return 
	
func send_message_to_server(username : String, message : String) :
	$MainClient.send(TcpPayload.new().set_type(TcpPayload.TYPE.SEND_CHAT_MESSAGE).set_content({"username" : username, "message" : message}))

signal disconnected

func _on_main_client_disconnected() -> void:
	disconnected.emit()
	queue_free()
	pass # Replace with function body.


func _on_main_client_payload_received(payload: TcpPayload) -> void:
	match payload.get_type():
		_:
			printerr("Unkown type %s" % payload.get_type())
	pass # Replace with function body.


func _on_main_client_accepted() -> void:
	pass # Replace with function body.
