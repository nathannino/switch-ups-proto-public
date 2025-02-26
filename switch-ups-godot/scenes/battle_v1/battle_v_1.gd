extends Control

signal preinit_complete
var player_id : int

signal sync_team

@export var timer : Timer
@export var interrupt_anchor : Control

@export_category("Action Menu")
@export var action_box : Control
@export var main_action_menu : Control

@export_category("Move list")
@export var move_list : Control

#region required by actions
var friend_team : Array[ms_spirit_active] = []
var enemy_team : Array[ms_spirit_active] = []

var current_action : ms_action
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
	_increase_action_index()
	handle_action_component()
	pass
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
	ClientWrapperAutoload.battle_team_synced.connect(_set_team_state)
	action_box.hide()
	
	timer.wait_time = 3 # Simulate a battle begin animation or smth
	timer.timeout.connect(func () : 
		ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_AWAIT_ENDTURN))
	, CONNECT_ONE_SHOT)
	timer.start()

func begin_turn() :
	action_box.show()
	main_action_menu.reset_center()

func get_spirit_in_field(_team : Array[ms_spirit_active], pos : ms_constants.POSITION) -> ms_spirit_active :
	match pos :
		ms_constants.POSITION.LEFT :
			return _team[1]
		ms_constants.POSITION.RIGHT : 
			return _team[2]
		ms_constants.POSITION.CENTER : 
			return _team[0]
		_ :
			return null

func submit_action_component() :
	print(action_data)
	pass

func _get_latest_component() :
	var _current_component : ms_action_component = current_action.get_child_component(action_index[0])
	if _current_component == null : return null
	for _action_index_index_fake in range(action_index.size() - 1) :
		var _action_index_index = _action_index_index_fake + 1 #because we have custom handling for the first entry
		var _action_index = action_index[_action_index_index]
		_current_component = _current_component.get_child_component(_action_index)
		if _current_component == null : return null
	return _current_component

# TODO : Move this somewhere more reusable... maybe turn this into it's own reusable scene?
func _increase_action_index() :
	var _current_component : ms_action_component = _get_latest_component()
	
	if _current_component == null :
		if action_index.size() <= 1 :
			printerr("Cannot increase action index")
			return
		action_index.pop_back()
		action_index[-1] += 1
		return
	
	if _current_component.get_child_component(0) == null :
		action_index[-1] += 1
		return
	
	action_index.push_back(0)
	return

func handle_action_component() :
	var _root_component : ms_action_component = current_action.get_child_component(action_index[0])
	
	if _root_component == null :
		submit_action_component()
		return
	
	var _current_component : ms_action_component = _get_latest_component()
	
	if _current_component == null :
		action_index.pop_back()
		action_index[-1] += 1
		handle_action_component()
		return
	
	var precommit = _current_component.get_precommit()
	
	if precommit == null : 
		_increase_action_index()
		handle_action_component()
		return
	
	interrupt_anchor.add_child(precommit)
	interrupt_anchor.show()
	precommit.attach_ready(self)
	return

func _on_move_selected(_index: int, _action: ms_action) -> void:
	current_action = _action
	action_data = []
	action_index = [0]
	
	move_list.hide()
	handle_action_component()
