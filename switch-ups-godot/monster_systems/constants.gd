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

static func stats_to_bbcode(type : STATS) :
	match type :
		STATS.CON_ATK:
			return TranslationServer.translate("TR_CONST_STATS_CONATK")
		STATS.ABS_ATK:
			return TranslationServer.translate("TR_CONST_STATS_ABSATK")
		STATS.DEF:
			return TranslationServer.translate("TR_CONST_STATS_DEF")
		STATS.SPEED:
			return TranslationServer.translate("TR_CONST_STATS_SPEED")
		STATS.LUCK:
			return TranslationServer.translate("TR_CONST_STATS_LUCK")

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
}
