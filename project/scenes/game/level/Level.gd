extends Node2D

onready var game_handler = get_parent()

onready var __next_level_transition_timer = $NextLeveTransitionTimer

var player_node

var __convert_player_scrap_to_score = false

func set_player_stats(stats: Dictionary):
	player_node.stats.set_from_data(stats)

func start_player_scrap_to_score_conversion():
	__convert_player_scrap_to_score = true
	
func _physics_process(delta):
	if __convert_player_scrap_to_score:
		if player_node.stats.get_scrap_count() > 0:
			player_node.stats.convert_scrap_to_score()
		else:
			__convert_player_scrap_to_score = false
			__next_level_transition_timer.start()


func _on_NextLeveTransitionTimer_timeout():
	game_handler.update_player_data(player_node.stats.get_data())
	game_handler.set_current_to_next_level()
