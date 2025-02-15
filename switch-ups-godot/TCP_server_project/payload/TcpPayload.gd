extends RefCounted

class_name TcpPayload

enum TYPE {
	ASK_VER,
	ERR_DISCONNECT,
	ASK_VER_ACCEPTED,
	SEND_MESSAGE,
	
	# Chat exclusive
	GET_HISTORY,
	SEND_CHAT_HISTORY,
	SEND_CHAT_MESSAGE
}
const PROTOCOL_VER = game_info.version

var type : TYPE
var content : Variant

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
