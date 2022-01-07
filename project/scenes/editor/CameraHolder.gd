extends Node2D
var __drag_pos: Vector2
var __pressed = false
onready var __camera = $Camera2D

func _input(event):
	if !Input.is_action_pressed("editor_pan_camera"): return
	if event is InputEventMouseMotion:
		var motion_event = event as InputEventMouseMotion
		__camera.position.x += motion_event.relative.x
