extends Node2D
var __drag_pos: Vector2
var __pressed = false

func _input(event):
	if !Input.is_action_pressed("editor_pan_camera"): return
	if event is InputEventMouseMotion:
		var motion_event = event as InputEventMouseMotion
		position.x -= motion_event.relative.x
