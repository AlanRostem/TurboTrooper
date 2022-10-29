extends Control

signal game_started()

onready var __start_label = $StartLabel

var __is_playing_game = false

func _physics_process(delta):
	# Start the game when pressing start. This signal is forwarded 
	# to GameHandler
	if Input.is_action_just_pressed("pause") and !__is_playing_game:
		emit_signal("game_started")
		visible = false
		__is_playing_game = true

# Flashing the "Press start" text like classic 
func _on_StartFlashTimer_timeout():
	__start_label.visible = !__start_label.visible


func _on_GameHandler_game_completed():
	__is_playing_game = false
	visible = true
