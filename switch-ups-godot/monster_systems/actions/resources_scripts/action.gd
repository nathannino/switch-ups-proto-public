extends Resource

class_name ms_action

@export var key : String
@export var name : String
@export_multiline var desc : String
@export var type : ms_constants.TYPE
@export var cost : int

@export var effects : Array[ms_action_component]
