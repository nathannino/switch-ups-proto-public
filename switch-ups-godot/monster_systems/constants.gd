extends Node

class_name ms_constants

enum TYPE {
	RETRO,
	CREATURE,
	DREAM,
	FEAR,
	VOID,
	NATURE,
	CONSTRUCT,
	SPACE,
	META,
	NORMAL
}

static func type_to_bbcode(type : TYPE) :
	match type :
		TYPE.RETRO :
			return "Retro"
		TYPE.CREATURE :
			return "Creature"
		TYPE.DREAM :
			return "Dream"
		TYPE.FEAR :
			return "Fear"
		TYPE.VOID :
			return "Void"
		TYPE.NATURE :
			return "Nature"
		TYPE.CONSTRUCT :
			return "Construct"
		TYPE.SPACE :
			return "Space"
		TYPE.META :
			return "Meta"
		TYPE.NORMAL :
			return "Normal"

enum ATK_FLAVOR {
	CONCRETE,
	ABSTRACT
}
