extends Node2D
var __drag_pos: Vector2
var __pressed = false
onready var __camera = $Camera2D

func _process(delta):
	if Input.is_action_just_pressed("editor_pan_camera"):
		__pressed = true
		__drag_pos = __camera.position + get_global_mouse_position()
	elif Input.is_action_just_released("editor_pan_camera"):
		__pressed = false

func _input(event):
	if event is InputEventMouseMotion and __pressed:
		__camera.position = __drag_pos - get_global_mouse_position()
