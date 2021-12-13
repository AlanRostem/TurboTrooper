extends Node

func is_last_level(index):
	return index == get_child_count() - 1

func get_level_scene(index):
	return get_child(index).level_scene
