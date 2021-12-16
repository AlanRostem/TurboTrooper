extends Node2D

onready var game_handler = get_parent()

var player_node

var __convert_player_scrap_to_score = false

func start_player_scrap_to_score_conversion():
	__convert_player_scrap_to_score = true
	
func _physics_process(delta):
	if __convert_player_scrap_to_score:
		if player_node.stats.get_scrap_count() > 0:
			player_node.stats.convert_scrap_to_score()
		else:
			__convert_player_scrap_to_score = false
