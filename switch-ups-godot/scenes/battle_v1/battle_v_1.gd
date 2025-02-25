extends Control

signal preinit_complete
var player_id : int

var friend_team : Array[ms_spirit_active] = []
var enemy_team : Array[ms_spirit_active] = []
signal sync_team

@export var timer : Timer

@export_category("Action Menu")
@export var action_box : Control
@export var main_action_menu : Control

func _init() :
	player_id = DeferredLoadingManager.get_holding_data(DeferredLoadingManager.add_prefix(ClientWrapperAutoload.AWAIT_PREFIX,TcpPayload.TYPE.BATTLE_SETUP_PLAYERID))
	_set_team_state(DeferredLoadingManager.get_holding_data(DeferredLoadingManager.add_prefix(ClientWrapperAutoload.AWAIT_PREFIX,TcpPayload.TYPE.BATTLE_SETUP_SYNCTEAM)))
	ClientWrapperAutoload.battle_all_loaded.connect.call_deferred(func() :
		preinit_complete.emit.call_deferred()
	, CONNECT_ONE_SHOT)
	ClientWrapperAutoload.send.call_deferred(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_AWAIT_INIT).set_content(null))

func _set_team_state(teams : Array) :
	for index in range(teams.size()) :
		var team_dict = teams[index]
		var team : Array[ms_spirit_active] = []
		for dict in team_dict :
			team.push_back(ms_spirit_active.from_dict(dict))
		if index == player_id :
			friend_team = team
		else :
			enemy_team = team
	if not is_node_ready() :
		await ready
		sync_team.emit()

func _ready() :
	ClientWrapperAutoload.battle_begin_turn.connect(begin_turn)
	action_box.hide()
	
	timer.wait_time = 3 # Simulate a battle begin animation or smth
	timer.timeout.connect(func () : 
		ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_AWAIT_ENDTURN))
	, CONNECT_ONE_SHOT)
	timer.start()

func begin_turn() :
	action_box.show()
	main_action_menu.reset_center()
