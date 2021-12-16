extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"


func physics_update(delta):
	player.set_velocity_x(-player.max_walk_speed)
