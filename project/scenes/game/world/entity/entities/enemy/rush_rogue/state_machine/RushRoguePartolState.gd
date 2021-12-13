extends "res://scenes/game/world/entity/entities/enemy/rush_rogue/state_machine/RushRogueState.gd"

func physics_update(delta):
	if rush_rogue.is_on_wall():
		rush_rogue.horizontal_looking_direction *= -1
	rush_rogue.set_velocity_x(MAX_PATROL_SPEED * rush_rogue.horizontal_looking_direction)
