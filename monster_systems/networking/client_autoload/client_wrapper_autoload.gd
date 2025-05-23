extends Node

@export var error_root : Control

#region Client signals
signal teambuilder_request_team
signal battle_team_synced(teams : Array)
signal battle_all_loaded
signal battle_begin_turn
signal battle_logs(logs)
signal request_data(request)
signal hide_cancel(hide)
signal cancel_ACKed
#endregion

var connected = false
signal connected_ack

const AWAIT_PREFIX = "packet"

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
	
func send(payload : TcpPayload) :
	client_scene.send(payload)

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

func get_signal_anonymous_func(payload_type : TcpPayload.TYPE) : # I hate this
	return func() : 
		while not DeferredLoadingManager.is_ready(DeferredLoadingManager.add_prefix(AWAIT_PREFIX,payload_type)) :
			OS.delay_msec(1)
		return DeferredLoadingManager.get_holding_data(DeferredLoadingManager.add_prefix(AWAIT_PREFIX,payload_type))


func _on_main_client_payload_received(payload: TcpPayload) -> void:
	match payload.get_type():
		TcpPayload.TYPE.CHANGE_SCENE :
			var dict = payload.get_content()
			var keys = []
			for _key in dict["packet_await"] :
				keys.push_back(DeferredLoadingManager.add_prefix(AWAIT_PREFIX,int(_key)))
			DeferredLoadingManager.change_scene(
				SceneLoadWrapper.create().from_key(dict["scene_key"]).with_await_keys(keys).background_await().prepare(),
				SceneLoadWrapper.create().as_transition(dict["transition_key"]).prepare()
			)
			send(TcpPayload.new().set_type(TcpPayload.TYPE.CHANGE_SCENE_RECEIVED))
		TcpPayload.TYPE.TEAMBUILD_LAST_TEAM, TcpPayload.TYPE.BATTLE_SETUP_PLAYERID, TcpPayload.TYPE.BATTLE_SETUP_BATTLEENV, TcpPayload.TYPE.BATTLE_SETUP_MUSICID, TcpPayload.TYPE.RESULT_PLAYERID, TcpPayload.TYPE.RESULT_TEAMS:
			DeferredLoadingManager._set_holding_data(DeferredLoadingManager.add_prefix(AWAIT_PREFIX,payload.get_type()),payload.get_content())
		TcpPayload.TYPE.BATTLE_SETUP_SYNCTEAM :
			DeferredLoadingManager._set_holding_data(DeferredLoadingManager.add_prefix(AWAIT_PREFIX,payload.get_type()),payload.get_content())
			battle_team_synced.emit(payload.get_content())
		TcpPayload.TYPE.TEAMBUILD_REQUEST_TEAM :
			teambuilder_request_team.emit()
		TcpPayload.TYPE.BATTLE_AWAIT_INIT :
			battle_all_loaded.emit()
		TcpPayload.TYPE.BATTLE_STARTTURN :
			battle_begin_turn.emit()
		TcpPayload.TYPE.BATTLE_LOGS :
			battle_logs.emit(payload.get_content())
		TcpPayload.TYPE.BATTLE_REQUEST_DATA :
			request_data.emit(payload.get_content())
		TcpPayload.TYPE.BATTLE_HIDE_CANCEL :
			hide_cancel.emit(payload.get_content())
		TcpPayload.TYPE.BATTLE_AWAIT_ENDTURN_CANCEL_ACK :
			cancel_ACKed.emit()
		_:
			printerr("Unkown type %s" % payload.get_type())
	pass # Replace with function body.


func _on_main_client_accepted() -> void:
	connected_ack.emit()
	pass # Replace with function body.


func _on_main_client_error(reason: String) -> void:
	error_root.show_reason(reason)
	pass # Replace with function body.
