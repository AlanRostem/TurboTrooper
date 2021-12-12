extends AudioStreamPlayer

func _on_TemporarySoundEffect_finished():
	queue_free()
