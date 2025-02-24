extends Control

signal preinit_complete

func _init() :
	ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.SEND_MESSAGE).set_content(DeferredLoadingManager.get_holding_data(DeferredLoadingManager.add_prefix(ClientWrapperAutoload.AWAIT_PREFIX,TcpPayload.TYPE.BATTLE_SETUP_SYNCTEAM))))
	print(DeferredLoadingManager.get_holding_data(DeferredLoadingManager.add_prefix(ClientWrapperAutoload.AWAIT_PREFIX,TcpPayload.TYPE.BATTLE_SETUP_SYNCTEAM)))

func _ready() :
	ClientWrapperAutoload.send(TcpPayload.new().set_type(TcpPayload.TYPE.SEND_MESSAGE).set_content("DEBUG_READY_DONE"))
	pass
