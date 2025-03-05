extends RefCounted

class_name TcpPayload

enum TYPE {
	ASK_VER,
	ERR_DISCONNECT,
	ASK_VER_ACCEPTED,
	SEND_MESSAGE,
	
	# Chat poc exclusive
	GET_HISTORY,
	SEND_CHAT_HISTORY,
	SEND_CHAT_MESSAGE,
	
	# DeferredSceneManager
	CHANGE_SCENE,
	
	# Team setup
	TEAMBUILD_LAST_TEAM, # Sends the state of the last team, to not have to start from scratch
	TEAMBUILD_SET_READY_STATE,
	TEAMBUILD_REQUEST_TEAM,
	TEAMBUILD_SEND_TEAM,
	
	# battle
	BATTLE_SETUP_PLAYERID,
	BATTLE_SETUP_SYNCTEAM,
	BATTLE_SETUP_BATTLEENV,
	BATTLE_AWAIT_INIT,
	BATTLE_AWAIT_ENDTURN,
	BATTLE_STARTTURN,
	BATTLE_SUBMIT_ACTION,
	BATTLE_REQUEST_DATA,
	BATTLE_LOGS,
	BATTLE_HIDE_CANCEL
}
const PROTOCOL_VER = game_info.version + ("_dev" if game_info.dev else "")

var type : TYPE
var content : Variant = null

func parse_json(_string : String) -> TcpPayload :
	var json = JSON.new()
	if not json.parse(_string) == OK :
		print("JSON Parse Error: ", json.get_error_message(), " in ", _string, " at line ", json.get_error_line())
		return self
	var data = json.data
	type = data["type"]
	content = data["content"]
	return self

func set_type(_type : TYPE) -> TcpPayload :
	type = _type
	return self

func set_content(_content : Variant) -> TcpPayload :
	content = _content
	return self
	
func get_type() -> TYPE :
	return type

func get_content() -> Variant :
	return content

func get_sent_json() -> String :
	return JSON.stringify({"type":type,"content":content})
