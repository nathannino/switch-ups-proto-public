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
	var obj = Object.new() #???????????
	var return_value = null
	match type :
		TYPE.RETRO :
			return_value = obj.tr("TR_CONST_TYPE_RETRO")
		TYPE.CREATURE :
			return_value = obj.tr("TR_CONST_TYPE_CREATURE")
		TYPE.DREAM :
			return_value = obj.tr("TR_CONST_TYPE_DREAM")
		TYPE.FEAR :
			return_value = obj.tr("TR_CONST_TYPE_FEAR")
		TYPE.VOID :
			return_value = obj.tr("TR_CONST_TYPE_VOID")
		TYPE.NATURE :
			return_value = obj.tr("TR_CONST_TYPE_NATURE")
		TYPE.CONSTRUCT :
			return_value = obj.tr("TR_CONST_TYPE_CONSTRUCT")
		TYPE.SPACE :
			return_value = obj.tr("TR_CONST_TYPE_SPACE")
		TYPE.META :
			return_value = obj.tr("TR_CONST_TYPE_META")
		TYPE.NORMAL :
			return_value = obj.tr("TR_CONST_TYPE_NORMAL")
	return return_value

enum ATK_FLAVOR {
	CONCRETE,
	ABSTRACT
}

static func flavor_to_bbcode(type : ATK_FLAVOR) :
	var obj = Object.new() #???????????
	var return_value = null
	match type :
		ATK_FLAVOR.CONCRETE :
			return_value = obj.tr("TR_CONST_FLAVOR_CONCRETE")
		ATK_FLAVOR.ABSTRACT :
			return_value = obj.tr("TR_CONST_FLAVOR_ABSTRACT")
	obj.free()
	return return_value
