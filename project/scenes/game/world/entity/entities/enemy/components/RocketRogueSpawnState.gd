extends "res://scenes/game/world/entity/entities/enemy/components/EnemyState.gd"

const MAX_RISE_SPEED = 40
const MAX_DISTANCE = 10

var __distance = 0

func enter(message):
	enemy.set_velocity_y(-MAX_RISE_SPEED)
	enemy.get_sprite().flip_h = enemy.horizontal_looking_direction < 0
	enemy.get_sprite().animation = "spawn"
	
func physics_update(delta):
	__distance -= MAX_RISE_SPEED * delta
	if __distance <= - MAX_DISTANCE:
		parent_state_machine.transition_to("RocketRogueRushState")
