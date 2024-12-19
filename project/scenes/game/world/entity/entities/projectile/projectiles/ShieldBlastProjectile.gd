extends Projectile


export(AudioStream) var __shoot_sound

func _ready():
	parent_world.play_sound(__shoot_sound)


func _on_ShieldBlastProjectile_target_hit(hitbox):
	if "Crate" in hitbox.get_parent().name:
		return
	if hitbox.get_parent() is Projectile:
		hitbox.get_parent().deflect(HitBox.PLAYER_TEAM, 12, parent_world.player_node.get_looking_vector())
		return
	destroy()
