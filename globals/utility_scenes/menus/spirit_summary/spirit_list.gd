extends VBoxContainer

var should_retry : bool
var should_end : bool
var is_looping : bool

var semaphore : Semaphore
var mutex : Mutex
var semaphoretwo : Semaphore
var thread : Thread

@export var button_root : Container
@export var button_template : PackedScene
@export var scrollbar : ScrollContainer
@export var signal_sender : Node

func _init() -> void:
	should_retry = false
	should_end = false
	is_looping = false
	semaphore = Semaphore.new()
	mutex = Mutex.new()
	semaphoretwo = Semaphore.new()
	thread = Thread.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thread.start(async_populate_grid)
	#print(button_root.ready_to_add)
	retry_list()
	pass # Replace with function body.

func delete_old() :
	#scrollbar.get_v_scroll_bar().set_deferred("value",0)
	for child in button_root.get_children() :
		button_root.remove_child(child)
		child.queue_free()

func retry_list() -> void :
	mutex.lock()
	should_retry = true
	semaphore.post()
	semaphoretwo.wait()
	delete_old()
	mutex.unlock()

func check_exit() -> bool :
	mutex.lock()
	var exit_time = should_end
	mutex.unlock()
	return exit_time

func check_retry() -> bool :
	mutex.lock()
	var retry_time = should_retry
	mutex.unlock()
	return retry_time

func async_populate_grid() :
	while true :
		semaphore.wait()
		semaphoretwo.post()
		mutex.lock()
		should_retry = false
		mutex.unlock()
		
		if check_exit() : return
		
		var sorted_array = SpiritDictionary.spirits.values().duplicate()
		sorted_array.sort_custom(func (a,b) : return a.name.naturalnocasecmp_to(b.name) < 0)
		
		for spirit in sorted_array :
			if check_exit() : return
			if check_retry() : break
			var button = button_template.instantiate()
			#button_root.add_child.call_deferred(button)
			button.set_spirit.call_deferred(spirit)
			button.pressed.connect(func () : 
				signal_sender.changed_selection.emit(spirit)
			)
			add_child_to_container(button)
	pass

func add_child_to_container(child : Node) :
	button_root.ready_to_add.lock()
	button_root.child_to_add.push_back(child)
	button_root.ready_to_add.unlock()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE :
			exit_tree()

func exit_tree() -> void:
	mutex.lock()
	should_end = true
	should_retry = true
	semaphore.post()
	mutex.unlock()
	if thread.is_started() :
		thread.wait_to_finish()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
