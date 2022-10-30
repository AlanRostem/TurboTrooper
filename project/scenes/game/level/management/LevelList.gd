extends Node
# This is a node that holds children that take an export value of a level
# scene that will be used in the instancing of a level when a level is 
# chosen. 


func is_last_level(index):
	return index == get_child_count() - 1

func get_level_scene(index):
	return get_child(index).level_scene
