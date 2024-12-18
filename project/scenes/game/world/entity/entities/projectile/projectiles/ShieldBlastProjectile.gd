extends Projectile


export(AudioStream) var __shoot_sound

func _ready():
	parent_world.play_sound(__shoot_sound)


func _on_ShieldBlastProjectile_target_hit(hitbox):
	if hitbox.get_parent() is DestructibleStructure:
		return
	if hitbox.get_parent() is Projectile:
		return
	destroy()
