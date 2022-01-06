extends "res://scenes/editor/tool/CanvasTool.gd"


var __entity = null


func on_place():
	__entity = get_canvas().get_entity_at_tile(get_mouse_location())


func on_place_held():
	if __entity == null : return
	if !get_canvas().is_tile_occupied(get_mouse_location()):
		__entity.position = get_canvas().tile_to_position(get_mouse_location())
	else:
		var other_entity = get_canvas().get_entity_at_tile(get_mouse_location())
		if other_entity == null: return
		if other_entity.is_y_sort_disabled() != __entity.is_y_sort_disabled():
			__entity.position = get_canvas().tile_to_position(get_mouse_location())
