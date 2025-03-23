extends Node

@export var server_client_wrapper : PackedScene
@export var error_root : Control
@export var battle_subscenes : scene_dictionary

const MAX_PLAYERS = 2

enum BATTLE_STEPS {
	NONE,
	SELECT_ACTION,
	CALCULATE_MOVES,
	AWAIT_MODIFICATION,
	RESUME_MOVES,
}

var battle_next : BATTLE_STEPS = BATTLE_STEPS.NONE

func _ready() -> void:
	battle_subscenes.populate_scene_dictionary()

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
	var battle_scene_def = battle_subscenes.get_scene_dictionary().values().pick_random()
	
	for child in $ServerMain.get_children() :
		child.state_startbattle(battle_scene_def.key)

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

const MAX_NATURAL_STAMINA = 5

func battle_next_main() :
	match battle_next :
		BATTLE_STEPS.SELECT_ACTION :
			$ServerMain.send_all(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_HIDE_CANCEL).set_content(false))
			for child in $ServerMain.get_children() :
				var _team = child.team
				_team[0].current_stamina = min(_team[0].current_stamina + 1, max(_team[0].current_stamina, MAX_NATURAL_STAMINA))
				_team[1].current_stamina = min(_team[1].current_stamina + 1, max(_team[1].current_stamina, MAX_NATURAL_STAMINA))
				_team[2].current_stamina = min(_team[2].current_stamina + 1, max(_team[2].current_stamina, MAX_NATURAL_STAMINA))
				for member in _team :
					member.is_defending = false
			for child in $ServerMain.get_children() :
				child.state_startturn()
			battle_next = BATTLE_STEPS.CALCULATE_MOVES
			pass
		BATTLE_STEPS.CALCULATE_MOVES :
			$ServerMain.send_all(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_HIDE_CANCEL).set_content(true))
			$TurnCalculator.start_turn()
		BATTLE_STEPS.AWAIT_MODIFICATION :
			battle_next = BATTLE_STEPS.RESUME_MOVES
			$TurnCalculator.send_request_data()
		BATTLE_STEPS.RESUME_MOVES :
			$TurnCalculator.calculate_next()
		_ :
			printerr("No next step : %s" % battle_next)

func battle_submit_logs_middle(logs) :
	battle_next = BATTLE_STEPS.AWAIT_MODIFICATION
	_battle_submit_logs(logs)
	pass

func battle_submit_logs_end(logs) :
	battle_next = BATTLE_STEPS.SELECT_ACTION
	_battle_submit_logs(logs)
	pass

func _battle_submit_logs(logs) :
	$ServerMain.send_all(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_LOGS).set_content(logs))
	pass

func _on_server_main_client_disconnected() -> void:
	# Let's keep it simple and just send everyone back
	for child in $ServerMain.get_children() :
		if child.in_battle : # Check to not lose info, since we don't sync teams in teambuild state
			child.state_teambuilding()
	pass # Replace with function body.
