extends Control

var __heart_sprite_texture = preload("res://assets/sprites/ui/hud/health.png")
onready var __flash_timer = $FlashTimer


func set_health(count):
	if count != 1:
		__flash_timer.stop()
		visible = true
	else:
		__flash_timer.start()
	for node in $Hearts.get_children():
		node.queue_free()
	for i in range(count):
		var heart = Sprite.new()
		$Hearts.add_child(heart)
		heart.position.x = i * 8
		heart.texture = __heart_sprite_texture

# Flashes the health bar 
func _on_FlashTimer_timeout():
	visible = !visible
