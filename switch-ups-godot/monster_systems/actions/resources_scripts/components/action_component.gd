extends Resource

class_name ms_action_component

#TODO : add the functions used by the server and the client here
# https://www.youtube.com/watch?v=vzRZjM9MTGw

func get_desc() -> Node :
	printerr("no description set")
	return Control.new()
