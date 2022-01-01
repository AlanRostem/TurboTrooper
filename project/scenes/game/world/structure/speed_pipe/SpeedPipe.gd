extends Node2D

func _on_PlayerDetectionArea_body_entered(player):
	player.visible = false


func _on_PlayerDetectionArea_body_exited(player):
	player.visible = true
