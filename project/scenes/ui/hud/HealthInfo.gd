extends Control


onready var __health_label = $HealthLabel
# onready var __heart_icon = $HeartIcon

onready var __flash_timer = $FlashTimer


func set_health(count):
	if count != 1:
		__flash_timer.stop()
		visible = true
	else:
		__flash_timer.start()
	__health_label.text = "-" + str(count)

# Flashes the health bar 
func _on_FlashTimer_timeout():
	visible = !visible
