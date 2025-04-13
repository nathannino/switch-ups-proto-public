extends Control

signal preinit_complete
var player_id : int

signal sync_team
signal turn_start
signal battlelog_start
signal battlelog_next

signal cancelled_action_exdata
signal spirit_rotation(teamid,oldpos,newpos)
signal spirit_switch(teamid_one,pos_one,spirit_one,teamid_two,pos_two,spirit_two)

@export var timer : Timer
@export var interrupt_anchor : Control
@export var await_cancel : Control
@export var battle_env_root : Control
@export var ui_globals : Node
@export var summary_container : Control

var battle_env_top : Control
const BATTLE_ENV_TOP_SCENE = preload("uid://dxrerm5c44rry")

var battle_env : Node3D :
	get: return battle_env_top.get_env()

var battle_logs = null
var battle_logs_await = 0

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

@export_category("logs")
@export var log_container : Container


var placeover_list = []

func _placeover_place(_label, _teamid : int, _pos : ms_constants.POSITION, _offset : Vector2) :
	var _team = friend_character if _teamid == player_id else enemy_character
	var _spirit = _team.get_spirit_anchor_from_pos(_pos)
	
	var ui_pos = battle_env.camera.unproject_position(_spirit.global_position) + _offset
	
	_label.global_position = ui_pos

var action_type : ms_constants.TYPE
#region required by actions
var friend_team : Array[ms_spirit_active] = []
var enemy_team : Array[ms_spirit_active] = []

func placeover_spirit_ui(_label : Control, _teamid : int, _pos : ms_constants.POSITION, _offset : Vector2 = Vector2.ZERO) :
	add_child(_label)
	
	var _args = [_label,_teamid,_pos,_offset]
	
	placeover_list.push_back(_args)
	_label.tree_exiting.connect(func() :
		placeover_list.erase(_args)
	, CONNECT_ONE_SHOT)
	
	_placeover_place(_label,_teamid,_pos,_offset)
	pass

func get_team_by_id(_id : int) :
	if _id == player_id :
		return friend_team
	else :
		return enemy_team

var current_action : ms_action
var current_action_index = 0
var action_data = []
var action_index = []

var friend_character : Node3D :
	get: return battle_env.friend_player

var enemy_character : Node3D :
	get: return battle_env.enemy_player

func pause_battle_log() :
	battle_logs_await += 1

func play_battle_log() :
	battle_logs_await -= 1

var is_request_data = false
var CANCEL = Object.new()
func submit_action_data(_data) :
	for child in interrupt_anchor.get_children() :
		child.queue_free()
	interrupt_anchor.hide()
	
	if _data is Object :
		if _data == CANCEL :
			# TODO : Special case for switch maybe?
			cancelled_action_exdata.emit()
			return
	
	
	if is_request_data :
		is_request_data = false
		ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_SUBMIT_DATA).set_content(_data))
		show_await_cancel_timer()
	else :
		action_data.push_back(_data)
		ms_action_index_manager.increase_action_index(ms_action_index_manager.get_latest_component(current_action,action_index),action_index)
		handle_action_component()
	pass

func get_selected_position() -> ms_constants.POSITION :
	return ui_globals.selected_position

func get_active_spirit(pid,sindex) :
	if pid == player_id :
		return friend_team[sindex]
	else :
		return enemy_team[sindex]

func get_3d_character(pid) :
	if pid == player_id :
		return friend_character
	else :
		return enemy_character

func change_player_hp(pid,change_value) :
	if pid == player_id :
		friend_hp += change_value
	else :
		enemy_hp += change_value

func show_summary(_spirit : ms_spirit_active) :
	summary_container.show()
	summary_container.set_summary_active(_spirit)

# TODO : Handle damage number, player damage, animations, etc...
func damage_visual(_pid : int,_spos : ms_constants.POSITION,_sdmg : float,_pdmg : float,_weak : ms_constants.WEAK_RES,_flavor : ms_constants.ATK_FLAVOR) :
	var char = friend_character if _pid == player_id else enemy_character
	var _color = Color(1,1,1)
	pause_battle_log()
	char.animation_done.connect(func() :
		play_battle_log()
	, CONNECT_ONE_SHOT)
	char.attack_3d(_spos,_sdmg,_pdmg,_weak,_flavor,_color)
	pass

func rotate_visual(pid_one,spirit_one_index,pid_two,spirit_two_index) :
	var team_one = friend_team if pid_one == player_id else enemy_team
	var team_3d_one = friend_character if pid_one == player_id else enemy_character
	var team_two = friend_team if pid_two == player_id else enemy_team
	var team_3d_two = friend_character if pid_two == player_id else enemy_character
	
	var spirit_one = team_one[spirit_one_index]
	var spirit_3d_one = team_3d_one.get_spirit_anchor_from_pos(ms_constants.index_to_position(spirit_one_index))
	var spirit_two = team_two[spirit_two_index]
	var spirit_3d_two = team_3d_two.get_spirit_anchor_from_pos(ms_constants.index_to_position(spirit_two_index))
	
	team_one[spirit_one_index] = spirit_two
	team_two[spirit_two_index] = spirit_one
	
	#region animations
	if spirit_3d_one == null and spirit_3d_two == null :
		return # There is no animations
	
	# Note that in this case, we make the same assumption sp_switch is doing
	if spirit_3d_one == null or spirit_3d_two == null :
		var _position = ms_constants.index_to_position(spirit_one_index) if not ms_constants.index_to_position(spirit_one_index) == ms_constants.POSITION.PARTY else ms_constants.index_to_position(spirit_two_index)
		var _new_spirit = spirit_one if ms_constants.index_to_position(spirit_one_index) == ms_constants.POSITION.PARTY else spirit_two
		
		camera_lookat_helper(ms_constants.POSITION.CENTER,pid_one if spirit_3d_two == null else pid_two)
		pause_battle_log()
		team_3d_one.animation_done.connect(func() :
			play_battle_log.call_deferred()
		,CONNECT_ONE_SHOT)
		team_3d_one.switch_spirit(_position, _new_spirit)
		spirit_switch.emit(pid_one,ms_constants.index_to_position(spirit_one_index),spirit_one,pid_two,ms_constants.index_to_position(spirit_two_index),spirit_two)
		pass # Switch time
	else :
		pause_battle_log()
		team_3d_two.rotate_spirit(spirit_3d_one,ms_constants.index_to_position(spirit_one_index),ms_constants.index_to_position(spirit_two_index),0)
		team_3d_one.rotate_spirit(spirit_3d_two,ms_constants.index_to_position(spirit_two_index),ms_constants.index_to_position(spirit_one_index),1)
		if team_3d_one == team_3d_two :
			camera_lookat_helper(ms_constants.POSITION.CENTER,pid_one)
			spirit_rotation.emit(pid_one,ms_constants.index_to_position(spirit_one_index),ms_constants.index_to_position(spirit_two_index))
		else :
			camera_lookat_helper()
			spirit_switch.emit(pid_one,ms_constants.index_to_position(spirit_one_index),spirit_one,pid_two,ms_constants.index_to_position(spirit_two_index),spirit_two)
			
		team_3d_one.animation_done.connect(func() :
			play_battle_log.call_deferred()
		,CONNECT_ONE_SHOT)
		pass # rotate time
	#endregion

func enter_log_text(_key : String, _format_vars : Dictionary = {}, _translated_format_vars : Dictionary = {}, _time : float = 0) :
	BattleLogPanel.add_log(_key,_format_vars,_translated_format_vars)
	log_container.add_battle_log(_key,_format_vars,_translated_format_vars,_time)
#endregion

func _init() :
	
	player_id = DeferredLoadingManager.get_holding_data(DeferredLoadingManager.add_prefix(ClientWrapperAutoload.AWAIT_PREFIX,TcpPayload.TYPE.BATTLE_SETUP_PLAYERID))
	_set_team_state(DeferredLoadingManager.get_holding_data(DeferredLoadingManager.add_prefix(ClientWrapperAutoload.AWAIT_PREFIX,TcpPayload.TYPE.BATTLE_SETUP_SYNCTEAM)))
	ClientWrapperAutoload.battle_all_loaded.connect.call_deferred(func() :
		preinit_complete.emit.call_deferred()
	, CONNECT_ONE_SHOT)
	
# this is so dumb...
func _deferred_init() :
	battle_env_top = BATTLE_ENV_TOP_SCENE.instantiate()
	battle_env_root.add_child(battle_env_top)

	battle_env_top.scene_loaded.connect(func() :
		ClientWrapperAutoload.send.call_deferred(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_AWAIT_INIT).set_content(null))
	)
	battle_env_top.load_scene(DeferredLoadingManager.get_holding_data(DeferredLoadingManager.add_prefix(ClientWrapperAutoload.AWAIT_PREFIX,TcpPayload.TYPE.BATTLE_SETUP_BATTLEENV)))

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
	
	friend_character.sync_spirits(friend_team)
	enemy_character.sync_spirits(enemy_team)
	sync_team.emit()

func camera_lookat_helper(_pos : ms_constants.POSITION = ms_constants.POSITION.PARTY, _pid : int = -1) :
	pause_battle_log()
	battle_env.cam_rotation_done.connect(
		_camera_rotation_done_callable
	, CONNECT_REFERENCE_COUNTED)
	if _pos == ms_constants.POSITION.PARTY :
		battle_env.camera_reset()
	else :
		battle_env.camera_look_at(_pos, _pid == player_id)

func _camera_rotation_done_callable() :
	play_battle_log()
	battle_env.cam_rotation_done.disconnect(_camera_rotation_done_callable)

var current_action_battle_log
func handle_battle_logs() :
	hide_await_cancel_timer()
	var log = battle_logs.pop_front()
	var battle_log_type : ms_constants.BATTLE_LOG = log.get("log_type",ms_constants.BATTLE_LOG.ACTION)
	match battle_log_type :
		ms_constants.BATTLE_LOG.ROTATE :
			var pid = log["pid"]
			var new_name = SpiritDictionary.spirits[get_active_spirit(pid,log["old_index"]).key].name
			var old_name = SpiritDictionary.spirits[get_active_spirit(pid,log["new_index"]).key].name
			
			if ms_constants.index_to_position(log["old_index"]) == ms_constants.POSITION.LEFT :
				enter_log_text("TR_BTLLOG_ROT_LEFT",{},{"old":old_name,"new":new_name},0.7)
			elif ms_constants.index_to_position(log["old_index"]) == ms_constants.POSITION.RIGHT :
				enter_log_text("TR_BTLLOG_ROT_RIGHT",{},{"old":old_name,"new":new_name},0.7)
			
			rotate_visual(pid,log["old_index"],pid,log["new_index"])
		ms_constants.BATTLE_LOG.START_ACTION :
			battlelog_next.emit()
			var log_player_id = log["pid"]
			var _team = friend_team if log_player_id == player_id else enemy_team
			var _spirit = _team[log["spirit"]]
			current_action_battle_log = _spirit.get_action(log["action"])
			
			action_type = current_action_battle_log.type
			
			const DELAY = 1.5
			
			var _spirit_name = SpiritDictionary.spirits[_spirit.key].name
			var _action_name = current_action_battle_log.name
			if log["success"] :
				_spirit.current_stamina -= current_action_battle_log.cost
				enter_log_text("TR_BTLLOG_USEACT_SUCCESS",{},{"spirit":_spirit_name,"action":_action_name},DELAY)
			else :
				enter_log_text("TR_BTLLOG_USEACT_FAILURE",{},{"spirit":_spirit_name,"action":_action_name},DELAY)
			
			camera_lookat_helper(ms_constants.POSITION.CENTER,log_player_id)
			pause_battle_log()
			timer.timeout.connect(func() :
				play_battle_log()
			, CONNECT_ONE_SHOT)
			timer.start(DELAY)
		ms_constants.BATTLE_LOG.ACTION :
			var target_info = log["target_info"]
			var log_player_id = target_info["user_id"]
			var _team = friend_team if log_player_id == player_id else enemy_team
			var _spirit = _team[target_info["user"]]
			var _action = current_action_battle_log
			var component = ms_action_index_manager.get_latest_component(_action,log["action_index_array"])
			
			component.handle_client(log, self)
			camera_lookat_helper(ms_constants.index_to_position(target_info["target"]),target_info["target_id"])

func _ready() :
	ClientWrapperAutoload.battle_begin_turn.connect(begin_turn)
	ClientWrapperAutoload.battle_team_synced.connect(_set_team_state)
	ClientWrapperAutoload.battle_logs.connect(func(_logs) :
		battlelog_start.emit.call_deferred()
		summary_container.hide()
		battle_logs = _logs
	)
	ClientWrapperAutoload.request_data.connect(handle_request_data)
	
	timer.wait_time = 0.5 # Simulate a battle begin animation or smth
	timer.timeout.connect(func () : 
		_begin_battle.call_deferred()
	, CONNECT_ONE_SHOT)
	timer.start()
	
	BattleLogPanel.clear()
	OptionsOverlay.set_in_battle(true)

func handle_request_data(content : Dictionary) :
	hide_await_cancel_timer()
	is_request_data = true
	action_data = []
	var _team = friend_team if content["team_index"] == player_id else enemy_team
	var _spirit = _team[content["spirit_index"]]
	var _action = _spirit.get_action(content["action_index"])
	
	var _component = ms_action_index_manager.get_latest_component(_action,content["component_index"])
	var _precommit = _component.get_interrupt_action()
	
	interrupt_anchor.add_child(_precommit)
	interrupt_anchor.show()
	_precommit.attach_ready(self)
	pass

func _begin_battle() :
	friend_character.begin_battle()
	enemy_character.begin_battle()
	friend_character.animation_done.connect(func() :
		ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_AWAIT_ENDTURN).set_content(true))
	,CONNECT_ONE_SHOT)

func begin_turn() :
	hide_await_cancel_timer()
	turn_start.emit()
	current_action = null
	action_data = []
	action_index = []

	BattleLogPanel.new_turn()
	camera_lookat_helper()

func get_spirit_in_field(_team : Array[ms_spirit_active], pos : ms_constants.POSITION) -> ms_spirit_active :
	return _team[ms_constants.position_to_index(pos)]

func submit_action_component() :
	ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_SUBMIT_ACTION).set_content(
		{
			"position_to_active" : ui_globals.selected_position,
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

	handle_action_component()

func _process(_delta: float) -> void:
	for _args in placeover_list :
		_placeover_place(_args[0], _args[1], _args[2], _args[3])
	
	if battle_logs is Array :
		if battle_logs_await > 0 :
			return
		if not battle_logs.is_empty() :
			handle_battle_logs()
		else :
			battlelog_next.emit()
			battle_logs = null
			ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.BATTLE_AWAIT_ENDTURN).set_content(true))
			show_await_cancel_timer()

func show_await_cancel_timer() :
	timer.wait_time = 0.5 # Simulate a battle begin animation or smth
	if not timer.timeout.is_connected(_await_cancel_timeout) :
		timer.timeout.connect(_await_cancel_timeout, CONNECT_ONE_SHOT)
	timer.start()

func hide_await_cancel_timer() :
	timer.stop()
	await_cancel.hide()
	if timer.timeout.is_connected(_await_cancel_timeout) :
		timer.timeout.disconnect(_await_cancel_timeout)
	pass

func _await_cancel_timeout() :
	await_cancel.show()

func _exit_tree() -> void:
	OptionsOverlay.set_in_battle(false)
