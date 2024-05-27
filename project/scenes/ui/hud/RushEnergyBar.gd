extends Control

const MAX_RUSH_ENERGY = 6

onready var __flash_timer = $FlashTimer

func set_rush_energy(count):
	if count > 0:
		__flash_timer.stop()
		visible = true
	else:
		__flash_timer.start()
	$TextureProgress.value = count
	

func _on_FlashTimer_timeout():
	visible = !visible
