extends Object

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

enum STATS {
	CON_ATK,
	ABS_ATK,
	DEF,
	SPEED,
	LUCK
}

static func stats_to_bbcode(type : STATS, translate = true) :
	match type :
		STATS.CON_ATK:
			return TranslationServer.translate("TR_CONST_STATS_CONATK") if translate else "TR_CONST_STATS_CONATK"
		STATS.ABS_ATK:
			return TranslationServer.translate("TR_CONST_STATS_ABSATK") if translate else "TR_CONST_STATS_ABSATK"
		STATS.DEF:
			return TranslationServer.translate("TR_CONST_STATS_DEF") if translate else "TR_CONST_STATS_DEF"
		STATS.SPEED:
			return TranslationServer.translate("TR_CONST_STATS_SPEED") if translate else "TR_CONST_STATS_SPEED"
		STATS.LUCK:
			return TranslationServer.translate("TR_CONST_STATS_LUCK") if translate else "TR_CONST_STATS_LUCK"

enum TARGETS {
	ALLY_SPIRIT,
	ALLY_EXCLUDE_SELF_SPIRIT,
	ALLY_SPOT,
	ALLY_EXCLUDE_SELF_SPOT,
	ENEMY_SPIRIT,
	ENEMY_EXCLUDE_ACTIVE_SPIRIT,
	ENEMY_SPOT,
	ENEMY_EXCLUDE_ACTIVE_SPOT,
	SELF_SPIRIT,
}

static func targets_to_bbcode(type : TARGETS) :
	match type :
		TARGETS.ALLY_SPIRIT :
			return TranslationServer.translate("TR_CONST_TARGET_ALLYSPIRIT")
		TARGETS.ALLY_EXCLUDE_SELF_SPIRIT :
			return TranslationServer.translate("TR_CONST_TARGET_ALLYEXCLUDESELFSPIRIT")
		TARGETS.ALLY_SPOT :
			return TranslationServer.translate("TR_CONST_TARGET_ALLYSPOT")
		TARGETS.ALLY_EXCLUDE_SELF_SPOT :
			return TranslationServer.translate("TR_CONST_TARGET_ALLYEXCLUDESELFSPOT")
		TARGETS.ENEMY_SPIRIT :
			return TranslationServer.translate("TR_CONST_TARGET_ENEMYSPIRIT")
		TARGETS.ENEMY_EXCLUDE_ACTIVE_SPIRIT :
			return TranslationServer.translate("TR_CONST_TARGET_ENEMYEXCLUDESELFSPIRIT")
		TARGETS.ENEMY_SPOT :
			return TranslationServer.translate("TR_CONST_TARGET_ENEMYSPOT")
		TARGETS.ENEMY_EXCLUDE_ACTIVE_SPOT :
			return TranslationServer.translate("TR_CONST_TARGET_ENEMYEXCLUDESELFSPOT")
		TARGETS.SELF_SPIRIT :
			return TranslationServer.translate("TR_CONST_TARGET_SELF")

enum POSITION {
	LEFT,
	CENTER,
	RIGHT,
	PARTY,
}

static func index_to_position(_index : int) :
	match _index:
		1: return POSITION.LEFT
		0: return POSITION.CENTER
		2: return POSITION.RIGHT
		_: return POSITION.PARTY

static func position_to_index(_pos : POSITION) :
	match _pos :
		POSITION.LEFT :
			return 1
		POSITION.CENTER :
			return 0
		POSITION.RIGHT :
			return 2

enum BATTLE_LOG {
	ROTATE,
	START_ACTION,
	ACTION
}

enum ACTION_COMPONENT_HANDLE_STATE {
	REQUEST_DATA, # Check precommit data first
	REQUEST_DATA_CLIENT_REQUIRED, # Skip straight to asking the client
	GET_CHILD,
	GET_SIBLING,
}

enum ADDITIONNAL_ACTION_COMPONENT_EFFECTS {
	NOTHING,
	CLEAR_TARGET_ACTION_DATA
}

static func calculate_randomness(user : ms_spirit_active, target : ms_spirit_active) :
	var default_result = randf()
	default_result = max(default_result - (target.get_luck()/100),0.0) 
	default_result = min(default_result + (user.get_luck()/100),1.0)
	return default_result


enum WEAK_RES {
	WEAK,
	RES,
	NORMAL
}
#region Weakness table
# Defending : {Attacking}
const WEAKNESS_TABLE = {
	TYPE.RETRO : {
		TYPE.RETRO : WEAK_RES.NORMAL,
		TYPE.CREATURE : WEAK_RES.NORMAL,
		TYPE.DREAM : WEAK_RES.NORMAL,
		TYPE.FEAR : WEAK_RES.RES,
		TYPE.VOID : WEAK_RES.RES,
		TYPE.NATURE : WEAK_RES.WEAK,
		TYPE.CONSTRUCT : WEAK_RES.NORMAL,
		TYPE.SPACE : WEAK_RES.WEAK,
		TYPE.META : WEAK_RES.WEAK,
		TYPE.NORMAL : WEAK_RES.NORMAL,
	},
	TYPE.CREATURE : {
		TYPE.RETRO : WEAK_RES.NORMAL,
		TYPE.CREATURE : WEAK_RES.WEAK,
		TYPE.DREAM : WEAK_RES.RES,
		TYPE.FEAR : WEAK_RES.WEAK,
		TYPE.VOID : WEAK_RES.NORMAL,
		TYPE.NATURE : WEAK_RES.RES,
		TYPE.CONSTRUCT : WEAK_RES.NORMAL,
		TYPE.SPACE : WEAK_RES.NORMAL,
		TYPE.META : WEAK_RES.WEAK,
		TYPE.NORMAL : WEAK_RES.NORMAL,
	},
	TYPE.DREAM : {
		TYPE.RETRO : WEAK_RES.NORMAL,
		TYPE.CREATURE : WEAK_RES.NORMAL,
		TYPE.DREAM : WEAK_RES.RES,
		TYPE.FEAR : WEAK_RES.WEAK,
		TYPE.VOID : WEAK_RES.RES,
		TYPE.NATURE : WEAK_RES.NORMAL,
		TYPE.CONSTRUCT : WEAK_RES.WEAK,
		TYPE.SPACE : WEAK_RES.NORMAL,
		TYPE.META : WEAK_RES.WEAK,
		TYPE.NORMAL : WEAK_RES.NORMAL,
	},
	TYPE.FEAR : {
		TYPE.RETRO : WEAK_RES.NORMAL,
		TYPE.CREATURE : WEAK_RES.RES,
		TYPE.DREAM : WEAK_RES.WEAK,
		TYPE.FEAR : WEAK_RES.WEAK,
		TYPE.VOID : WEAK_RES.WEAK,
		TYPE.NATURE : WEAK_RES.RES,
		TYPE.CONSTRUCT : WEAK_RES.RES,
		TYPE.SPACE : WEAK_RES.NORMAL,
		TYPE.META : WEAK_RES.WEAK,
		TYPE.NORMAL : WEAK_RES.NORMAL,
	},
	TYPE.VOID : {
		TYPE.RETRO : WEAK_RES.WEAK,
		TYPE.CREATURE : WEAK_RES.NORMAL,
		TYPE.DREAM : WEAK_RES.NORMAL,
		TYPE.FEAR : WEAK_RES.NORMAL,
		TYPE.VOID : WEAK_RES.RES,
		TYPE.NATURE : WEAK_RES.RES,
		TYPE.CONSTRUCT : WEAK_RES.WEAK,
		TYPE.SPACE : WEAK_RES.NORMAL,
		TYPE.META : WEAK_RES.WEAK,
		TYPE.NORMAL : WEAK_RES.NORMAL,
	},
	TYPE.NATURE : {
		TYPE.RETRO : WEAK_RES.RES,
		TYPE.CREATURE : WEAK_RES.WEAK,
		TYPE.DREAM : WEAK_RES.NORMAL,
		TYPE.FEAR : WEAK_RES.NORMAL,
		TYPE.VOID : WEAK_RES.RES,
		TYPE.NATURE : WEAK_RES.NORMAL,
		TYPE.CONSTRUCT : WEAK_RES.NORMAL,
		TYPE.SPACE : WEAK_RES.WEAK,
		TYPE.META : WEAK_RES.WEAK,
		TYPE.NORMAL : WEAK_RES.NORMAL,
	},
	TYPE.CONSTRUCT : {
		TYPE.RETRO : WEAK_RES.WEAK,
		TYPE.CREATURE : WEAK_RES.NORMAL,
		TYPE.DREAM : WEAK_RES.NORMAL,
		TYPE.FEAR : WEAK_RES.NORMAL,
		TYPE.VOID : WEAK_RES.RES,
		TYPE.NATURE : WEAK_RES.WEAK,
		TYPE.CONSTRUCT : WEAK_RES.NORMAL,
		TYPE.SPACE : WEAK_RES.RES,
		TYPE.META : WEAK_RES.WEAK,
		TYPE.NORMAL : WEAK_RES.NORMAL,
	},
	TYPE.SPACE : {
		TYPE.RETRO : WEAK_RES.RES,
		TYPE.CREATURE : WEAK_RES.RES,
		TYPE.DREAM : WEAK_RES.WEAK,
		TYPE.FEAR : WEAK_RES.NORMAL,
		TYPE.VOID : WEAK_RES.WEAK,
		TYPE.NATURE : WEAK_RES.NORMAL,
		TYPE.CONSTRUCT : WEAK_RES.WEAK,
		TYPE.SPACE : WEAK_RES.RES,
		TYPE.META : WEAK_RES.WEAK,
		TYPE.NORMAL : WEAK_RES.NORMAL,
	},
	TYPE.META : {
		TYPE.RETRO : WEAK_RES.WEAK,
		TYPE.CREATURE : WEAK_RES.WEAK,
		TYPE.DREAM : WEAK_RES.WEAK,
		TYPE.FEAR : WEAK_RES.WEAK,
		TYPE.VOID : WEAK_RES.NORMAL,
		TYPE.NATURE : WEAK_RES.WEAK,
		TYPE.CONSTRUCT : WEAK_RES.WEAK,
		TYPE.SPACE : WEAK_RES.WEAK,
		TYPE.META : WEAK_RES.WEAK,
		TYPE.NORMAL : WEAK_RES.WEAK,
	},
	TYPE.NORMAL : {
		TYPE.RETRO : WEAK_RES.NORMAL,
		TYPE.CREATURE : WEAK_RES.NORMAL,
		TYPE.DREAM : WEAK_RES.NORMAL,
		TYPE.FEAR : WEAK_RES.NORMAL,
		TYPE.VOID : WEAK_RES.NORMAL,
		TYPE.NATURE : WEAK_RES.NORMAL,
		TYPE.CONSTRUCT : WEAK_RES.NORMAL,
		TYPE.SPACE : WEAK_RES.NORMAL,
		TYPE.META : WEAK_RES.WEAK,
		TYPE.NORMAL : WEAK_RES.NORMAL,
	},
}

static func _get_hit_type(atk_type : TYPE,def_type : TYPE) -> WEAK_RES:
	return WEAKNESS_TABLE[def_type][atk_type]
#endregion

static func get_hit_type(atk_type : TYPE,main_def_type : TYPE, sub_def_type = null) -> WEAK_RES :
	if not sub_def_type == null :
		if _get_hit_type(atk_type,sub_def_type) == WEAK_RES.WEAK :
			return WEAK_RES.WEAK
	
	return _get_hit_type(atk_type,main_def_type)
