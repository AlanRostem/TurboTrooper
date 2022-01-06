tool
extends TextureButton


onready var __editor = get_parent().get_parent().get_parent()
export var __tile_set = preload("res://assets/resources/tile_set/MainTileSet.tres") setget set_tile_set
export(Texture) var __icon = null setget set_icon
export(PackedScene) var __entity = null setget set_entity


func set_icon(value):
	__icon = value
	$Sprite.texture = value

func set_entity(value):
	__entity = value

func set_tile_set(tile_set):
	__tile_set = tile_set
	set_entity(__entity)

func _on_EntityButton_pressed():
	__editor.get_editor_canvas().get_canvas_tool().set_entity_stroke(__entity)
