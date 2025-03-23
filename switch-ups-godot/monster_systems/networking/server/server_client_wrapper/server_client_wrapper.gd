extends Node

const MAX_HEALTH = 300

# TODO : Make sure this is reset when needed, this is very important state to sync omg
#region Client variables
var teambuilding_is_ready = false
var teambuilding_received_team = false
var in_battle = false 
var battle_loaded = false
var team_id = 0
var team = []
var start_turn_team_state = []
var player_health = 0
var await_endturn = false
var selected_action_dict = null
#endregion

var change_scene_callable = func () : pass

#func change_scene(_scene_key : String, _trans_key : String, _await_payloads : Array[TcpPayload.TYPE], response : Callable) :
#	change_scene_callable = response

#region state setters
func state_teambuilding() :
	reset_team_stats()
	teambuilding_is_ready = false
	teambuilding_received_team = false
	change_scene("build_team","wipe_rect",[TcpPayload.TYPE.TEAMBUILD_LAST_TEAM], func() :
		send(TcpPayload.new().set_type(TcpPayload.TYPE.TEAMBUILD_LAST_TEAM).set_content(team_to_dict()))
	)

func state_startbattle(scene_key : String) :
	reset_team_stats()
	in_battle = true
	battle_loaded = false
	await_endturn = false
	selected_action_dict = null
	team_id = get_parent().get_children().find(self)
	change_scene("battle_v1","fade_to_black",[TcpPayload.TYPE.BATTLE_SETUP_PLAYERID,TcpPayload.TYPE.BATTLE_SETUP_BATTLEENV, TcpPayload.TYPE.BATTLE_SETUP_SYNCTEAM],func () :
		send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_SETUP_PLAYERID).set_content(get_index()))
		send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_SETUP_BATTLEENV).set_content(scene_key))
		sync_teams()
	)

func state_startturn() :
	sync_teams()
	selected_action_dict = null
	send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_STARTTURN))
#endregion

func sync_teams() :
	var teams = []
	for child in get_parent().get_children() :
		teams.push_back({"hp":child.player_health,"team":child.team_to_dict()})
	send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_SETUP_SYNCTEAM).set_content(teams))

func team_to_dict() :
	var dict_team = []
	for member in team :
		dict_team.push_back(member.to_dict())
	return dict_team

func reset_team_stats() :
	player_health = MAX_HEALTH
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
			await_endturn = payload.get_content()
			global_payload_received.emit(self,payload)
		TcpPayload.TYPE.BATTLE_SUBMIT_ACTION :
			selected_action_dict = payload.get_content()
		TcpPayload.TYPE.CHANGE_SCENE_RECEIVED :
			change_scene_callable.call()
			change_scene_callable = func() : pass
			pass
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

func change_scene(scene_key,transition_key,packet_await = [], response = func() : pass) :
	change_scene_callable = response
	send(TcpPayload.new().set_type(TcpPayload.TYPE.CHANGE_SCENE).set_content({"scene_key":scene_key,"transition_key":transition_key,"packet_await":packet_await}))

func _on_server_client_node_accepted() -> void:
	state_teambuilding()
	pass # Replace with function body.
