extends Node
#BGM that can survive a scene change. 

@onready var player_one = $AudioStreamPlayerOne
@onready var player_two = $AudioStreamPlayerTwo

const database_path = "res://bgm/database/"
const DATABASE_LOAD_KEY = "bgm_database"
var database = null
var current_active = 0

@onready var mutex = Mutex.new()

@export var fade_sigular_duration : float
@export var crossfade_duration : float
const MIN_DB = -80
var already_overwritten = false

enum TRANSITIONS {
	CUT,
	FADE_OUT_CUT_IN,
	FADE_OUT_IN,
	CROSSFADE
}

func _end_tread(thread : Thread) :
	thread.wait_to_finish()

func switch_active() :
	current_active = 0 if current_active == 1 else 1

func _get_active() -> AudioStreamPlayer :
	return player_one if current_active == 0 else player_two

func _get_standby() -> AudioStreamPlayer :
	return player_two if current_active == 0 else player_one

func set_current_bgm() :
	pass

var music_thread_lock = false
func _unlock_music() :
	music_thread_lock = false

func _lock_music() :
	while music_thread_lock :
		OS.delay_msec(1)
	music_thread_lock = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DeferredLoadingManager._deferred_generation_thread(DATABASE_LOAD_KEY,load_database)
	pass # Replace with function body.

func _change_stream(song : bgm) :
	_get_active().stream = song.loop
	_get_active().play()

func _set_paused(stream : AudioStreamPlayer,paused : bool) :
	stream.stream_paused = paused

func _handle_standby(transition : TRANSITIONS, on_end : Callable, standby : AudioStreamPlayer) :
	match transition :
		TRANSITIONS.CUT :
			on_end.call()
		TRANSITIONS.FADE_OUT_CUT_IN, TRANSITIONS.FADE_OUT_IN :
			if (standby.playing) :
				var tween = get_tree().create_tween()
				tween.tween_property(standby,"volume_db",MIN_DB,fade_sigular_duration)
				await tween.finished
				on_end.call()
		TRANSITIONS.CROSSFADE :
			if (standby.playing) :
				var tween = get_tree().create_tween()
				tween.tween_property(standby,"volume_db",MIN_DB,crossfade_duration)
				tween.finished.connect(func() :
					on_end.call()
				, CONNECT_ONE_SHOT)

func _handle_active(transition : TRANSITIONS, active : AudioStreamPlayer) :
	call_deferred("_set_paused",active,false)
	match transition :
		TRANSITIONS.CUT, TRANSITIONS.FADE_OUT_CUT_IN :
			active.volume_db = linear_to_db(1)
		TRANSITIONS.FADE_OUT_IN :
			var tween = get_tree().create_tween()
			tween.tween_property(active,"volume_db",linear_to_db(1),fade_sigular_duration)
			await tween.finished
		TRANSITIONS.CROSSFADE :
			var tween = get_tree().create_tween()
			tween.tween_property(active,"volume_db",linear_to_db(1),crossfade_duration)
			await tween.finished

func play(key : String, transition : TRANSITIONS) :
	var thread = Thread.new()
	thread.start(func() :
		_lock_music()
		await _play(key,transition)
		_unlock_music()
		call_deferred("_end_tread",thread)
	)

func _play(key : String, transition : TRANSITIONS) :
	while database == null :
		OS.delay_msec(1)
	var song = database[key]
	already_overwritten = false
	
	if _get_active().stream == song.loop :
		return
	
	switch_active()
	var active = _get_active()
	var standby = _get_standby()
	
	active.volume_db = MIN_DB
	call_deferred("_change_stream",song)
	
	await _handle_standby(transition,func () : standby.call_deferred("stop") ,standby)
	
	active.call_deferred("play")
	
	await _handle_active(transition, active)
	return
	

# Temporarely change the song without losing progress on the previous one. Currently only supports one layer of override
func play_override(key : String, transition : TRANSITIONS) :
	var thread = Thread.new()
	thread.start(func() :
		_lock_music()
		await _play_override(key, transition)
		_unlock_music()
		call_deferred("_end_tread",thread)
	)

func _play_override(key : String, transition : TRANSITIONS) :
	var song = database[key]
	
	if already_overwritten : #FIXME : Maybe handle override transitions? If needed?
		call_deferred("_change_stream",song)
		return
	already_overwritten = true
	
	switch_active()
	var active = _get_active()
	var standby = _get_standby()
	
	active.volume_db = MIN_DB
	call_deferred("_change_stream",song)
	
	await _handle_standby(transition,func () : call_deferred("_set_paused",standby,true) ,standby)
	
	active.call_deferred("play")
	
	await _handle_active(transition, active)
	pass

func stop_override(transition : TRANSITIONS) :
	var thread = Thread.new()
	thread.start(func() : 
		_lock_music()
		await _stop_override(transition)
		_unlock_music()
		call_deferred("_end_tread",thread)
	)

func _stop_override(transition : TRANSITIONS) :
	if not already_overwritten :
		return
	switch_active()
	already_overwritten = false
	var active = _get_active()
	var standby = _get_standby()
	
	active.volume_db = MIN_DB
	
	await _handle_standby(transition,func () : standby.call_deferred("stop") ,standby)
	
	await _handle_active(transition, active)
	pass

func stop(transition : TRANSITIONS) :
	var thread = Thread.new()
	thread.start(func() : 
		_lock_music()
		await _stop(transition)
		_unlock_music()
		call_deferred("_end_tread",thread)
	)

func _stop(transition : TRANSITIONS) :
	already_overwritten = false
	var active = _get_active()
	
	await _handle_standby(transition, func () : active.call_deferred("stop"), active) 

func load_database() :
	var files = DirAccess.get_files_at(database_path)
	var database = {}
	print("Discovering BGM")
	for file : String in files :
		file = file.replace(".remap","")
		if file.ends_with(".tres") :
			var entry = load(database_path + file)
			database[entry.key] = entry 
			print("BGM : %s" % entry.key)
	print("BGM loaded")
	return database

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if database == null :
		var _database = DeferredLoadingManager.get_holding_data(DATABASE_LOAD_KEY)
		if _database is Dictionary :
			database = _database
			DeferredLoadingManager.forget([DATABASE_LOAD_KEY])
	pass
