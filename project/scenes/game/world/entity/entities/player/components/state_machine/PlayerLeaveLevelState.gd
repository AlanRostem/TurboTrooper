extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

func enter(message):
	if player.stats.has_weapon():
		player.stats.get_weapon().set_can_attack(false)

func physics_update(delta):
	player.set_velocity_x(-PlayerSpeedValues.PLAYER_WALK_SPEED)
