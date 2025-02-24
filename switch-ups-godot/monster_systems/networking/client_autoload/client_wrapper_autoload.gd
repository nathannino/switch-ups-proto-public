extends Node

@export var error_root : Control

#region Client signals
signal teambuilder_request_team
signal battle_team_synced(teams : Array)
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
			var preload_dict = {}
			for entry in dict["packet_await"] :
				preload_dict[DeferredLoadingManager.add_prefix(AWAIT_PREFIX,entry)] = get_signal_anonymous_func(entry)
			DeferredLoadingManager.change_scene(
			SceneLoadWrapper.create().from_key(dict["scene_key"]).with_preloaded_generations(preload_dict).background_await().prepare(),
			SceneLoadWrapper.create().as_transition(dict["transition_key"]).prepare()
			)
		TcpPayload.TYPE.TEAMBUILD_LAST_TEAM, TcpPayload.TYPE.BATTLE_SETUP_PLAYERID:
			DeferredLoadingManager._set_holding_data(DeferredLoadingManager.add_prefix(AWAIT_PREFIX,payload.get_type()),payload.get_content())
		TcpPayload.TYPE.BATTLE_SETUP_SYNCTEAM :
			DeferredLoadingManager._set_holding_data(DeferredLoadingManager.add_prefix(AWAIT_PREFIX,payload.get_type()),payload.get_content())
			battle_team_synced.emit(payload.get_content())
		TcpPayload.TYPE.TEAMBUILD_REQUEST_TEAM :
			teambuilder_request_team.emit.call_deferred()
		_:
			printerr("Unkown type %s" % payload.get_type())
	pass # Replace with function body.


func _on_main_client_accepted() -> void:
	connected_ack.emit()
	pass # Replace with function body.


func _on_main_client_error(reason: String) -> void:
	error_root.show_reason(reason)
	pass # Replace with function body.
