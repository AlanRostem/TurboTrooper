extends "res://scenes/game/world/entity/entities/enemy/components/EnemyState.gd"

const WALK_SPEED = 30

var __explosion_effect_scene = preload("res://scenes/game/world/other/BoomCrawlerExplosionEffect.tscn")

var __direction = -1

func physics_update(delta):
	if enemy.is_on_wall():
		__direction *= -1
	enemy.set_velocity_x(__direction * WALK_SPEED)

func _on_OutHitBox_hit_dealt(hitbox):
	if hitbox.get_parent() is Player:
		enemy.die()
		enemy.parent_world.show_effect_deferred(__explosion_effect_scene, enemy.position)


func _on_BoomCrawler_player_detected(player):
	__direction = enemy.get_horizontal_player_detect_direction()
