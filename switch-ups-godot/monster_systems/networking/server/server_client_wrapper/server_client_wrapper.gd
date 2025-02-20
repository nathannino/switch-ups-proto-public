extends Node

# TODO : Make sure this is reset when needed, this is very important state to sync omg
#region Client variables
var teambuilding_is_ready = false
var team = []
#endregion

func peer_ready(_peer : StreamPeerTCP) -> void:
	if ServerWrapper.get_connections() > ServerWrapper.MAX_PLAYERS :
		$ServerClientNode.peer_refused(_peer)
	else :
		$ServerClientNode.peer_ready(_peer)

signal disconnected

signal global_payload_received(_self : Node, _payload : TcpPayload)

func _on_server_client_node_payload_received(payload: TcpPayload) -> void:
	match payload.get_type() :
		TcpPayload.TYPE.TEAMBUILD_SET_READY_STATE :
			teambuilding_is_ready = payload.get_content()
			global_payload_received.emit(self,payload)
		TcpPayload.TYPE.TEAMBUILD_SEND_TEAM :
			var temp_team = payload.get_content()
			team.clear()
			for member in temp_team :
				team.push_back(ms_spirit_active.from_dict(member))
			print(temp_team)
		_:
			printerr("Unkown type %s" % payload.get_type())
	pass # Replace with function body.

func disconnect_from_server(reason = "ERR_SERVER_GENERIC") :
	$ServerClientNode.disconnect_from_server(true,reason)

func _on_server_client_node_disconnected() -> void:
	disconnected.emit()
	queue_free()
	pass # Replace with function body.
	
func send(_payload : TcpPayload) -> void :
	$ServerClientNode.send(_payload)

func change_scene(scene_key,transition_key) :
	send(TcpPayload.new().set_type(TcpPayload.TYPE.CHANGE_SCENE).set_content({"scene_key":scene_key,"transition_key":transition_key}))

func _on_server_client_node_accepted() -> void:
	change_scene("build_team","wipe_rect")
	pass # Replace with function body.
