extends "res://scenes/game/level/Level.gd"
class_name PurgeLevel

var __kill_count = 0
var __max_kill_count = 0

func add_one_required_kill():
	__max_kill_count += 1
	game_handler.get_hud().set_global_message("purged:" + str(__kill_count) + "-" + str(__max_kill_count))	
	
func add_one_kill():
	__kill_count += 1
	game_handler.get_hud().set_global_message("purged:" + str(__kill_count) + "-" + str(__max_kill_count))
