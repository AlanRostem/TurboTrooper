extends Area2D

const MAX_LAUNCH_SPEED = 230

onready var __eject_sound = $EjectSound

func _on_LaunchPad_body_entered(player):
	player.set_velocity_y(-MAX_LAUNCH_SPEED)
	__eject_sound.play()
