extends Control


onready var __canvas = $CanvasLayer/Canvas
onready var __tiles = $MenuLayer/Tiles
onready var __entities = $MenuLayer/Entities
onready var __tools = $MenuLayer/Tools
onready var __tile_tween = $MenuLayer/Tiles/TileTween
onready var __entities_tween = $MenuLayer/Entities/EntitiesTween
onready var __tools_tween = $MenuLayer/Tools/ToolsTween
onready var __camera = $CanvasLayer/Canvas/CameraHolder/Camera2D


func get_editor_canvas():
	return __canvas

func _on_TilesButton_toggled(button_pressed):
	if button_pressed:
		__tile_tween.interpolate_property(__tiles, "rect_position:x", __tiles.rect_position.x, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	else:
		__tile_tween.interpolate_property(__tiles, "rect_position:x", __tiles.rect_position.x, -__tiles.rect_size.x, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	__tile_tween.start()

func _on_EntitiesButton_toggled(button_pressed):
	if button_pressed:
		__entities_tween.interpolate_property(__entities, "rect_position:x", __entities.rect_position.x, rect_size.x - __entities.rect_size.x, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	else:
		__entities_tween.interpolate_property(__entities, "rect_position:x", __entities.rect_position.x, rect_size.x, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	__entities_tween.start()

func _on_ToolsButton_toggled(button_pressed):
	if button_pressed:
		__tools_tween.interpolate_property(__tools, "rect_position:y", __tools.rect_position.y, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	else:
		__tools_tween.interpolate_property(__tools, "rect_position:y", __tools.rect_position.y, -__tools.rect_size.y, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	__tools_tween.start()

func _on_PauseButton_pressed():
	get_tree().paused = !get_tree().paused
