extends Resource

class_name ms_action_component

#TODO : add the functions used by the server and the client here
# https://www.youtube.com/watch?v=vzRZjM9MTGw

func get_desc() -> Node :
	printerr("no description set")
	return Control.new()

func get_child_component(_index : int) -> ms_action_component :
	return null

func get_precommit() -> Control :
	return null

func serv_requires_interrupt() -> bool :
	return false

func get_interrupt_action() -> Control :
	return null
