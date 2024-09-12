extends Node2D
class_name Level

enum MusicThemes {
	CAVE,
	LAB,
	FACTORY,
}

onready var game_handler = get_parent()

onready var __game_world = $GameWorld
onready var __check_point = $CheckPoint

var player_node

var __convert_player_scrap_to_score = false
var __has_check_point = false

export(MusicThemes) var __theme = MusicThemes.CAVE

func _ready():
	if __has_check_point:
		player_node.state_machine.transition_to("PlayerIdleState")
	else:
		player_node.state_machine.transition_to("PlayerEnterLevelState")
	
func play_battle_theme():
	game_handler.start_battle_sequence()
	
func stop_battle_theme():
	game_handler.cancel_battle_sequence()
	
func get_player_node():
	return $GameWorld/EntityPool/Player
	
func get_theme_enum():
	return __theme
	
func set_check_point_enabled(value):
	__has_check_point = true
	
func set_check_point_location(vec):
	__check_point.position = vec
	
func has_check_point():
	return __has_check_point
	
func get_game_world():
	return __game_world
	
func save_check_point():
	game_handler.set_check_point(__check_point.position)
	player_node.stats.set_check_point(__check_point.position)
	
func set_saved_player_scrap(scrap):
	player_node.stats.call_deferred("set_scrap", scrap)
	
func put_player_on_check_point(vec):
	player_node.position = vec
	
func set_remove_all_entities(value):
	__game_world.set_remove_all_entities(value)

func set_player_stats(stats: Dictionary):
	player_node.stats.set_from_data(stats)
	if game_handler.has_check_point():
		put_player_on_check_point(player_node.stats.get_check_point())

func start_player_scrap_to_score_conversion():
	__convert_player_scrap_to_score = true

func _physics_process(delta):
	if __convert_player_scrap_to_score:
		if player_node.stats.get_scrap_count() > 0:
			player_node.stats.convert_scrap_to_score(1)
			player_node.stats.convert_scrap_to_score(1)
			player_node.stats.convert_scrap_to_score(1)
			player_node.stats.convert_scrap_to_score(1)
		else:
			__convert_player_scrap_to_score = false
			game_handler.start_transitioning_to_next_level()

func _on_NextLeveTransitionTimer_timeout():
#	game_handler.update_player_data(player_node.stats.get_data())
	game_handler.set_current_to_next_level()
	
func _on_ResetTimer_timeout():
	game_handler.reset_current_level()
