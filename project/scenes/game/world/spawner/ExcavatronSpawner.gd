extends "res://scenes/game/world/spawner/Spawner.gd"



func _on_ExcavatronSpawner_spawned_entity(entity):
	entity.set_direction(Vector2.DOWN)
