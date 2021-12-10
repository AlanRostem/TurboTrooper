extends Node2D
	
signal completed()
	
var _completion_cond_data = {}
	
func update_completion_condition(key, value):
	_completion_cond_data[key] = value
	if is_completed():
		emit_signal("completed")
	
func is_completed():
	return false
