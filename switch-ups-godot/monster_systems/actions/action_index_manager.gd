extends Object
class_name ms_action_index_manager

enum INCREASE_RESULT {
	GO_DOWN,
	STAY,
	GO_UP
}

static func get_latest_component(current_action : ms_action, action_index) :
	var _current_component : ms_action_component = current_action.get_child_component(action_index[0])
	if _current_component == null : return null
	for _action_index_index_fake in range(action_index.size() - 1) :
		var _action_index_index = _action_index_index_fake + 1 #because we have custom handling for the first entry
		var _action_index = action_index[_action_index_index]
		_current_component = _current_component.get_child_component(_action_index)
		if _current_component == null : return null
	return _current_component

static func increase_action_index(_current_component : ms_action_component, action_index) -> INCREASE_RESULT :
	if _current_component == null :
		if action_index.size() <= 1 :
			printerr("Cannot increase action index")
			return INCREASE_RESULT.STAY
		action_index.pop_back()
		action_index[-1] += 1
		return INCREASE_RESULT.GO_UP
	
	if _current_component.get_child_component(0) == null :
		action_index[-1] += 1
		return INCREASE_RESULT.STAY
	
	action_index.push_back(0)
	return INCREASE_RESULT.GO_DOWN
