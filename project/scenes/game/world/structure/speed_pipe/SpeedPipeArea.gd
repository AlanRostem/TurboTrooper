extends Node2D

signal player_entered()

func _on_PlayerDetectionArea_body_entered(player):
	player.visible = false
	if player.state_machine.get_current_state() == "PlayerSlideState":
		emit_signal("player_entered")

func _on_PlayerDetectionArea_body_exited(player):
	player.visible = true
