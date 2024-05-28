extends Area2D
class_name LaunchPad

onready var __eject_sound = $EjectSound

func _on_LaunchPad_body_entered(player):
	player.set_velocity_y(-PlayerSpeedValues.MAX_LAUNCH_SPEED)
	__eject_sound.play()
