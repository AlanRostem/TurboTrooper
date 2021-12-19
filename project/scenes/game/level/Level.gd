extends Node2D

onready var game_handler = get_parent()

onready var __intro_timer = $IntroTimer
onready var __reset_timer = $ResetTimer
onready var __next_level_transition_timer = $NextLevelTransitionTimer

onready var __color_rect = $CanvasLayer/ColorRect

onready var __game_world = $GameWorld
onready var __check_point = $CheckPoint

var player_node

var __convert_player_scrap_to_score = false

func _ready():
	__color_rect.visible = true
	if game_handler.has_check_point():
		player_node.state_machine.transition_to("PlayerIdleState")
	else:
		player_node.state_machine.transition_to("PlayerEnterLevelState")
	
func save_check_point():
	game_handler.set_check_point(__check_point.position, player_node.stats.get_scrap_count())
	
func set_saved_player_scrap(scrap):
	player_node.stats.set_scrap(scrap)
	
func put_player_on_check_point(vec):
	player_node.position = vec
	
func set_remove_all_entities(value):
	__game_world.set_remove_all_entities(value)
	
func start_reset_sequence():
	__reset_timer.start()

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

func _on_IntroTimer_timeout():
	__color_rect.visible = false


func _on_ResetTimer_timeout():
	game_handler.reset_current_level()
