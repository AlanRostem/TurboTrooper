extends Node2D
	
signal completed()
signal completion_transition_over()

export var __completion_transition_time = 3.0

onready var __parent_level = get_parent().get_parent().get_parent()

onready var __completion_transition_timer = $CompletionTransitionTimer

func complete():
	__completion_transition_timer.start(__completion_transition_time)
	__parent_level.set_remove_all_entities(true)
	__parent_level.game_handler.start_level_win_sequence()
	emit_signal("completed")
	
func get_parent_level():
	return __parent_level
	
func _on_CompletionTransitionTimer_timeout():
	emit_signal("completion_transition_over")
