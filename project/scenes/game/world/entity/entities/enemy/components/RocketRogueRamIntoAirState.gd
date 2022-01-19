extends "res://scenes/game/world/entity/entities/enemy/components/EnemyRamIntoAirState.gd"


func physics_update(delta):
	if enemy.is_on_ceiling():
		enemy.explode()
