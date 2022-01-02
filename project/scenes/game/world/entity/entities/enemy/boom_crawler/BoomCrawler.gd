extends Enemy

var __explosion_effect_scene = preload("res://scenes/game/world/other/BoomCrawlerExplosionEffect.tscn")

const WALK_SPEED = 30

var __direction = -1

func _physics_process(delta):
	if is_on_wall():
		__direction *= -1
	set_velocity_x(__direction * WALK_SPEED)

func _on_OutHitBox_hit_dealt_then_destroy_self(hitbox):
	if hitbox.get_parent() is Player:
		die()
		parent_world.show_effect_deferred(__explosion_effect_scene, position)

func _on_BoomCrawler_player_detected(player):
	__direction = get_horizontal_player_detect_direction()


