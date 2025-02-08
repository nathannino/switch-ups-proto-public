extends Resource
class_name ms_spirit

# TODO : Technically speaking, this is only a battle simulator, so I don't think we will need a level up system...
# But if we do get to make a level up system, this is not compatible at all...
@export var key : String
@export var name : String
@export var sprite : Texture2D
@export var type : ms_constants.TYPE

# ======[ Stats ]=====
# TODO : How to select base stats??
@export var health : int
@export var atk_concrete : int
@export var atk_abstract : int
@export var defense : int
@export var speed : int
@export var luck : int
