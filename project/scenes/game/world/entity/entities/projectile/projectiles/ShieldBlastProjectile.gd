extends Projectile


export(AudioStream) var __shoot_sound

func _ready():
	parent_world.play_sound(__shoot_sound)
