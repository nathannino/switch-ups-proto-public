extends Node

@export var server_client_wrapper : PackedScene
@export var error_root : Control

const MAX_PLAYERS = 2

enum BATTLE_STEPS {
	NONE,
	SELECT_ACTION,
	CALCULATE_MOVES,
	AWAIT_MODIFICATION,
}

var battle_next : BATTLE_STEPS = BATTLE_STEPS.NONE

func start_server(_bind_address : String, _port : int) -> bool :
	match $ServerMain.start_server(_bind_address,_port,server_client_wrapper,global_payload_received) :
		ERR_ALREADY_IN_USE :
			error_root.show_reason("ERR_PORT_IN_USE")
			return false
		_:
			return true

func close_server() :
	$ServerMain.close_server()

func change_scene_all(scene_key : String, transition_key : String) :
	$ServerMain.send_all(TcpPayload.new().set_type(TcpPayload.TYPE.CHANGE_SCENE).set_content({"scene_key":scene_key,"transition_key":transition_key}))

signal disconnected

func get_connections() -> int:
	return $ServerMain.get_child_count()

func set_state_teambuilding() :
	for child in $ServerMain.get_children() :
		child.state_teambuilding()

func set_state_battle_start() :
	battle_next = BATTLE_STEPS.NONE
	for child in $ServerMain.get_children() :
		child.state_startbattle()

func global_payload_received(_client : Node, payload : TcpPayload) -> void :
	match payload.get_type() :
		TcpPayload.TYPE.TEAMBUILD_SET_READY_STATE :
			var readys = 0
			for child in $ServerMain.get_children() :
				if child.teambuilding_is_ready :
					readys += 1
			if readys >= MAX_PLAYERS :
				$ServerMain.send_all(TcpPayload.new().set_type(TcpPayload.TYPE.TEAMBUILD_REQUEST_TEAM))
		TcpPayload.TYPE.TEAMBUILD_SEND_TEAM :
			var readys = 0
			for child in $ServerMain.get_children() :
				if child.teambuilding_received_team :
					readys += 1
			if readys >= MAX_PLAYERS :
				set_state_battle_start()
		TcpPayload.TYPE.BATTLE_AWAIT_INIT :
			var readys = 0
			for child in $ServerMain.get_children() :
				if child.battle_loaded :
					readys += 1
			if readys >= MAX_PLAYERS :
				battle_next = BATTLE_STEPS.SELECT_ACTION
				$ServerMain.send_all(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_AWAIT_INIT))
		TcpPayload.TYPE.BATTLE_AWAIT_ENDTURN :
			var readys = 0
			for child in $ServerMain.get_children() :
				if child.await_endturn :
					readys += 1
			if readys >= MAX_PLAYERS :
				for child in $ServerMain.get_children() :
					child.await_endturn = false
				battle_next_main()
		_ :
			printerr("Unkown global type : %s" % payload.get_type())
	pass

func battle_next_main() :
	match battle_next :
		BATTLE_STEPS.SELECT_ACTION :
			for child in $ServerMain.get_children() :
				var _team = child.team
				_team[0].current_stamina += 1
				_team[1].current_stamina += 1
				_team[2].current_stamina += 1
			for child in $ServerMain.get_children() :
				child.sync_teams()
				child.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_STARTTURN))
			pass
		_ :
			printerr("No next step : %s" % battle_next)

func _on_server_main_client_disconnected() -> void:
	# Let's keep it simple and just send everyone back
	for child in $ServerMain.get_children() :
		if child.in_battle : # Check to not lose info, since we don't sync teams in teambuild state
			child.state_teambuilding()
	pass # Replace with function body.
