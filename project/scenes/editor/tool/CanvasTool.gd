extends Node

onready var __canvas = get_parent()

var __placed = false
var __just_placed = false

var __removed = false
var __just_removed = false

var __tile_stroke = -1
var __entity_stroke = -1

func set_tile_stroke(type):
	__tile_stroke = type
	__entity_stroke = null

func set_entity_stroke(entity):
	__entity_stroke = entity
	__tile_stroke = -1

func get_tile_stroke():
	return __tile_stroke

func get_entity_stroke():
	return __entity_stroke

func get_canvas():
	return __canvas

func get_mouse_location():
	return __canvas.position_to_tile(__canvas.get_local_mouse_position())

func set_place(flag):
	__placed = flag
	__just_placed = flag

func set_remove(flag):
	__removed = flag
	__just_removed = flag

func _process(delta):
	if __just_placed:
		__just_placed = false
		on_place()
		on_place_held()
	elif __placed:
		on_place_held()
		
	if __just_removed:
		__just_removed = false
		on_remove()
		on_remove_held()
	elif __removed:
		on_remove_held()

func on_place():
	pass

func on_place_held():
	pass

func on_remove():
	pass

func on_remove_held():
	pass
