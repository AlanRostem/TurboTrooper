extends "res://scenes/game/world/structure/DestructibleStructure.gd"

var __explosion_scene = preload("res://scenes/game/world/entity/entities/hazard/Explosion.tscn")
var __sound_effect = preload("res://assets/audio/sfx/entities/explosive_barrel/explosive_barrel.wav")

func _destroyed():
	parent_world.spawn_entity_deferred(__explosion_scene, position)
	parent_world.play_sound(__sound_effect)
