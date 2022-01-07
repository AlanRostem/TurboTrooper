tool
extends TextureButton

onready var __editor = get_parent().get_parent().get_parent()
export var __tile_set = preload("res://assets/resources/MainTileSet.tres") setget set_tile_set
export var __type = -1 setget set_type


func set_type(value):
	__type = value
	var sprite = $Sprite
	sprite.texture = __tile_set.tile_get_texture(__type)
	var region = __tile_set.tile_get_region(__type)
	
	sprite.region_rect.position.x = region.position.x
	sprite.region_rect.position.y = region.position.y

func set_tile_set(tile_set):
	__tile_set = tile_set
	set_type(__type)

func _on_TileButton_pressed():
	__editor.get_editor_canvas().get_canvas_tool().set_tile_stroke(__type)
