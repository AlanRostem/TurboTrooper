extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

func enter(message):
	player.is_gravity_enabled = false
	
func physics_update(delta):
	player.set_velocity(Vector2.ZERO)
