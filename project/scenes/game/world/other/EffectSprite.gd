extends AnimatedSprite

func _ready():
	frame = 0
	play("default")

func _on_EffectSprite_animation_finished():
	queue_free()
