extends Node2D
var __drag_pos: Vector2
var __pressed = false
onready var __camera = $Camera2D

func _process(delta):
	if Input.is_action_just_pressed("editor_pan_camera"):
		__pressed = true
		__drag_pos.x = __camera.position.x + get_global_mouse_position().x
	elif Input.is_action_just_released("editor_pan_camera"):
		__pressed = false
		
	if __pressed:
		__camera.position.x = __drag_pos.x - get_global_mouse_position().x
