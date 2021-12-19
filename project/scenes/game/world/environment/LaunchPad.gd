extends Area2D

const MAX_LAUNCH_SPEED = 230

func _on_LaunchPad_body_entered(player):
	player.set_velocity_y(-MAX_LAUNCH_SPEED)
