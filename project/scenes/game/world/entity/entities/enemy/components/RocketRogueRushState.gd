extends "res://scenes/game/world/entity/entities/enemy/components/EnemyState.gd"


const MAX_RUSH_SPEED = 110

func enter(message):
	enemy.get_sprite().animation = "rush"
	enemy.set_body_shape_enabled(true)

func physics_update(delta):
	enemy.set_velocity_y(0)
	enemy.set_velocity_x(enemy.horizontal_looking_direction * MAX_RUSH_SPEED)
	if enemy.is_on_wall():
		enemy.explode()
