extends Control

signal preinit_complete
var player_id : int

signal sync_team

@export var timer : Timer
@export var interrupt_anchor : Control
@export var await_cancel : Control

var _friend_hp = 0.0
signal friend_hp_changed(old,new)
var friend_hp : float :
	get : return _friend_hp
	set(value) :
		var old = _friend_hp
		_friend_hp = value
		friend_hp_changed.emit(old,value)

var _enemy_hp = 0.0
signal enemy_hp_changed(old,new)
var enemy_hp : float :
	get : return _enemy_hp
	set(value) :
		var old = _enemy_hp
		_enemy_hp = value
		enemy_hp_changed.emit(old,value)

@export_category("Action Menu")
@export var action_box : Control
@export var main_action_menu : Control

@export_category("Move list")
@export var move_list : Control

@export_category("teams")
@export var enemy_team_ui : Control
@export var friend_team_ui : Control


#region required by actions
var friend_team : Array[ms_spirit_active] = []
var enemy_team : Array[ms_spirit_active] = []

var current_action : ms_action
var current_action_index = 0
var action_data = []
var action_index = []

var CANCEL = Object.new()
func submit_action_data(_data) :
	for child in interrupt_anchor.get_children() :
		child.queue_free()
	interrupt_anchor.hide()
	
	if _data is Object :
		if _data == CANCEL :
			# TODO : Special case for switch maybe?
			move_list.show()
			return
	
	action_data.push_back(_data)
	ms_action_index_manager.increase_action_index(ms_action_index_manager.get_latest_component(current_action,action_index),action_index)
	handle_action_component()
	pass


func get_selected_position() -> ms_constants.POSITION :
	return main_action_menu.spirit_position

func get_active_spirit(pid,sindex) :
	if pid == player_id :
		return friend_team[sindex]
	else :
		return enemy_team[sindex]

func change_player_hp(pid,change_value) :
	if pid == player_id :
		friend_hp += change_value
	else :
		enemy_hp += change_value

func rotate_visual(pid_one,spirit_one_index,pid_two,spirit_two_index) :
	var team_one = friend_team if pid_one == player_id else enemy_team
	var team_two = friend_team if pid_two == player_id else enemy_team
	
	var spirit_one = team_one[spirit_one_index]
	var spirit_two = team_two[spirit_two_index]
	
	#TODO : Animations =D
	#WARNING : Animations should take into consideration the posibility of a target not being active at the moment
	
	team_one[spirit_one_index] = spirit_two
	team_two[spirit_two_index] = spirit_one
	
	enemy_team_ui.sync_team_state()
	friend_team_ui.sync_team_state()
#endregion

func _init() :
	player_id = DeferredLoadingManager.get_holding_data(DeferredLoadingManager.add_prefix(ClientWrapperAutoload.AWAIT_PREFIX,TcpPayload.TYPE.BATTLE_SETUP_PLAYERID))
	_set_team_state(DeferredLoadingManager.get_holding_data(DeferredLoadingManager.add_prefix(ClientWrapperAutoload.AWAIT_PREFIX,TcpPayload.TYPE.BATTLE_SETUP_SYNCTEAM)))
	ClientWrapperAutoload.battle_all_loaded.connect.call_deferred(func() :
		preinit_complete.emit.call_deferred()
	, CONNECT_ONE_SHOT)
	ClientWrapperAutoload.send.call_deferred(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_AWAIT_INIT).set_content(null))

func _notification(what: int) -> void:
	match what: 
		NOTIFICATION_PREDELETE :
			CANCEL.free()
			CANCEL = null

func _set_team_state(teams : Array) :
	for index in range(teams.size()) :
		var player = teams[index]
		var team_dict = player["team"]
		var team : Array[ms_spirit_active] = []
		for dict in team_dict :
			team.push_back(ms_spirit_active.from_dict(dict))
		if index == player_id :
			friend_team = team
			friend_hp = player["hp"]
		else :
			enemy_team = team
			enemy_hp = player["hp"]
	if not is_node_ready() :
		await ready
	sync_team.emit()

var current_action_battle_log
func handle_battle_logs(battle_logs) :
	for log in battle_logs : #TODO : Animations
		var battle_log_type : ms_constants.BATTLE_LOG = log.get("log_type",ms_constants.BATTLE_LOG.ACTION)
		match battle_log_type :
			ms_constants.BATTLE_LOG.ROTATE :
				var pid = log["pid"]
				rotate_visual(pid,log["old_index"],pid,log["new_index"])
				continue
			ms_constants.BATTLE_LOG.START_ACTION :
				var log_player_id = log["pid"]
				var _team = friend_team if log_player_id == player_id else enemy_team
				var _spirit = _team[log["spirit"]]
				current_action_battle_log = _spirit.get_actions_combined_converted()[log["action"]]
				#TODO : dialog
				if log["success"] :
					_spirit.current_stamina -= current_action_battle_log.cost
				continue
			ms_constants.BATTLE_LOG.ACTION :
				pass # Honestly, probably won't be used
		var target_info = log["target_info"]
		var log_player_id = target_info["user_id"]
		var _team = friend_team if log_player_id == player_id else enemy_team
		var _spirit = _team[target_info["user"]]
		var _action = current_action_battle_log
		ms_action_index_manager.get_latest_component(_action,log["action_index_array"])
	ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_AWAIT_ENDTURN).set_content(true))

func _ready() :
	ClientWrapperAutoload.battle_begin_turn.connect(begin_turn)
	ClientWrapperAutoload.battle_team_synced.connect(_set_team_state)
	ClientWrapperAutoload.battle_logs.connect(handle_battle_logs)
	action_box.hide()
	
	timer.wait_time = 3 # Simulate a battle begin animation or smth
	timer.timeout.connect(func () : 
		ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_AWAIT_ENDTURN).set_content(true))
	, CONNECT_ONE_SHOT)
	timer.start()

func begin_turn() :
	current_action = null
	action_data = []
	action_index = []

	action_box.show()
	await_cancel.hide()
	main_action_menu.reset_center()

func get_spirit_in_field(_team : Array[ms_spirit_active], pos : ms_constants.POSITION) -> ms_spirit_active :
	return _team[ms_constants.position_to_index(pos)]

func submit_action_component() :
	ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_SUBMIT_ACTION).set_content(
		{
			"position_to_active" : main_action_menu.spirit_position,
			"action_index" : current_action_index, # Sending action index to have more freedom regarding forced switches
			"action_data" : action_data,
		}
	))
	ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_AWAIT_ENDTURN).set_content(true))
	await_cancel.show()

# TODO : Move this somewhere more reusable... maybe turn this into it's own reusable scene?

func handle_action_component() :
	var _root_component : ms_action_component = current_action.get_child_component(action_index[0])
	
	if _root_component == null :
		submit_action_component()
		return
	
	var _current_component : ms_action_component = ms_action_index_manager.get_latest_component(current_action,action_index)
	
	if _current_component == null :
		action_index.pop_back()
		action_index[-1] += 1
		handle_action_component()
		return
	
	var precommit = _current_component.get_precommit()
	
	if precommit == null : 
		ms_action_index_manager.increase_action_index(_current_component,action_index)
		handle_action_component()
		return
	
	interrupt_anchor.add_child(precommit)
	interrupt_anchor.show()
	precommit.attach_ready(self)
	return

func _on_move_selected(_index: int, _action: ms_action) -> void:
	current_action = _action
	current_action_index = _index
	action_data = []
	action_index = [0]
	
	move_list.hide()
	handle_action_component()
