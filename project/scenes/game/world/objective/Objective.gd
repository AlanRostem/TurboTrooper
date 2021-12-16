extends Node2D
	
signal completed()
signal completion_transition_over()

export var __completion_transition_time = 3.0

onready var __parent_level = get_parent().get_parent()

onready var __completion_transition_timer = $CompletionTransitionTimer

onready var __win_theme = $WinTheme

func complete():
	__completion_transition_timer.start(__completion_transition_time)
	__win_theme.play()
	emit_signal("completed")
	
func _on_CompletionTransitionTimer_timeout():
	emit_signal("completion_transition_over")
