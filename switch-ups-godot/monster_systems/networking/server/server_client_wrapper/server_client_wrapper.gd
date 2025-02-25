extends Node

# TODO : Make sure this is reset when needed, this is very important state to sync omg
#region Client variables
var teambuilding_is_ready = false
var teambuilding_received_team = false
var in_battle = false
var battle_loaded = false
var team = []
var await_endturn = false
#endregion

#region state setters
func state_teambuilding() :
	reset_team_stats()
	teambuilding_is_ready = false
	teambuilding_received_team = false
	in_battle = false
	battle_loaded = false
	var await_endturn = false
	change_scene("build_team","wipe_rect",[TcpPayload.TYPE.TEAMBUILD_LAST_TEAM])
	send(TcpPayload.new().set_type(TcpPayload.TYPE.TEAMBUILD_LAST_TEAM).set_content(team_to_dict()))

func state_startbattle() :
	reset_team_stats()
	teambuilding_is_ready = false
	teambuilding_received_team = false
	in_battle = true
	battle_loaded = false
	var await_endturn = false
	change_scene("battle_v1","fade_to_black",[TcpPayload.TYPE.BATTLE_SETUP_PLAYERID,TcpPayload.TYPE.BATTLE_SETUP_SYNCTEAM])
	
	send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_SETUP_PLAYERID).set_content(get_index()))
	sync_teams.call_deferred() # Making sure every server_client_wrapper had state_startbattle() called
#endregion

func sync_teams() :
	var teams = []
	for child in get_parent().get_children() :
		teams.push_back(child.team_to_dict())
	send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_SETUP_SYNCTEAM).set_content(teams))

func team_to_dict() :
	var dict_team = []
	for member in team :
		dict_team.push_back(member.to_dict())
	return dict_team

func reset_team_stats() :
	for member in team :
		member.reset_stats()

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
			teambuilding_received_team = true
			global_payload_received.emit(self,payload)
		TcpPayload.TYPE.BATTLE_AWAIT_INIT :
			battle_loaded = true
			global_payload_received.emit(self,payload)
		TcpPayload.TYPE.BATTLE_AWAIT_ENDTURN :
			await_endturn = true
			global_payload_received.emit(self,payload)
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

func change_scene(scene_key,transition_key,packet_await = []) :
	send(TcpPayload.new().set_type(TcpPayload.TYPE.CHANGE_SCENE).set_content({"scene_key":scene_key,"transition_key":transition_key,"packet_await":packet_await}))

func _on_server_client_node_accepted() -> void:
	state_teambuilding()
	pass # Replace with function body.
