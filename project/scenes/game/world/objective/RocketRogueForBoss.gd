extends Enemy

func _on_OutHitBox_hit_dealt_to_boss(hitbox):
	hitbox.take_hit(null, 60)


func explode():
	queue_free()
