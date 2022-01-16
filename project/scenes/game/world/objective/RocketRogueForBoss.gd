extends Enemy

var __explosion_effect = preload("res://scenes/game/world/other/RocketRogueExplosionEffect.tscn")

func _on_OutHitBox_hit_dealt_to_boss(hitbox):
	hitbox.take_hit(null, 60)
	explode()

func explode():
	queue_free()
	parent_world.show_effect_deferred(__explosion_effect, position)
