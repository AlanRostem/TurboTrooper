extends Control


onready var __canvas = $Canvas
onready var __tiles = $MenuLayer/Tiles
onready var __entities = $MenuLayer/Entities
onready var __tools = $MenuLayer/Tools
onready var __camera = $Canvas/CameraHolder/Camera2D
onready var __file_dialog = $MenuLayer/FileDialog


func get_editor_canvas():
	return __canvas

func _on_PauseButton_pressed():
	get_tree().paused = !get_tree().paused

func _on_SaveButton_pressed():
	__file_dialog.popup()
