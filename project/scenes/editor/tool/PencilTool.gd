extends "res://scenes/editor/tool/CanvasTool.gd"
class_name PencilTool

func on_place_held():
	if get_entity_stroke() != null:
		get_canvas().add_entity(get_entity_stroke(), get_mouse_location())
	else:
		get_canvas().set_tile(get_tile_stroke(), get_mouse_location())

func on_remove_held():
	get_canvas().remove_tile_or_entity_at_tile(get_mouse_location())
