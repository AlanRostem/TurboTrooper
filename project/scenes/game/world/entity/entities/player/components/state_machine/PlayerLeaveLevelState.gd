extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

var __dir = -1

func enter(message):
	if message.has("right"):
		__dir = 1
	if player.stats.has_weapon():
		player.stats.get_weapon().set_can_attack(false)

func physics_update(delta):
	player.set_velocity_x(__dir*PlayerSpeedValues.PLAYER_WALK_SPEED)
