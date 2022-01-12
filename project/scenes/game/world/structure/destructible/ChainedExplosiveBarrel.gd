extends "res://scenes/game/world/structure/DestructibleStructure.gd"

var __explosion_scene = preload("res://scenes/game/world/entity/entities/hazard/Explosion.tscn")

func _destroyed():
	parent_world.spawn_entity_deferred(__explosion_scene, position)
