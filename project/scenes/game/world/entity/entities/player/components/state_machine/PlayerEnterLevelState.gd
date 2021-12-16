extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

onready var __move_timer = $MoveTimer

var __move = false

func enter(message):
	player.set_velocity_y(0)
	player.is_gravity_enabled = false
	__move_timer.start()

func physics_update(delta):
	if !__move: return
	player.set_velocity_x(player.max_dash_speed)
	if player.is_on_ground():
		parent_state_machine.transition_to("PlayerIdleState")
		player.set_velocity_x(0)


func _on_MoveTimer_timeout():
	__move = true
	player.is_gravity_enabled = true
