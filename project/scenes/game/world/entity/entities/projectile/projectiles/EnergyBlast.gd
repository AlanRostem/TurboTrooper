extends Projectile

export(AudioStream) var __shoot_sound

func _ready():
	parent_world.play_sound(__shoot_sound)

func _on_HitBox_hit_dealt_to_counter(hitbox):
	var parent = hitbox.get_parent()
	if parent is Projectile:
		parent.destroy()
