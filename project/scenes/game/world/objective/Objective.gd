extends Node2D
	
signal completed()
	
var __completion_cond_data = {}
	
func update_completion_condition(key, value):
	__completion_cond_data[key] = value
	if is_completed():
		emit_signal("completed")
	
func is_completed():
	return false
