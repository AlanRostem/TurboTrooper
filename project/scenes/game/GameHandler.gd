extends Node2D


# Handles everything related to playing the game itself. This node swaps out levels when
# transitioning between them and handles the level selection world. This node also loads
# all save data about the player and manages the player's temporary in-game stats. With
# that in mind, all user interface, such as the pause menu and HUD, will be handled through
# the playable nodes themselves (such as a level and the level select world)

signal game_completed()

var __current_level = null

var __level_index = -1

onready var __hud = $CanvasLayer/HUD

onready var __level_list = $LevelList
onready var __pauseability_timer = $PauseabilityTimer
onready var __level_intro_timer = $LevelIntroTimer
onready var __reset_timer = $LevelResetTimer
onready var __color_rect = $CanvasLayer/ColorRect
onready var __next_level_transition_timer = $NextLevelTransitionTimer

var __has_check_point = false
var __can_pause = false
export var __has_completed_game = false

var __saved_player_stats = {
	"score": 0,
	"life": 3,
	"weapon": -1,
	"scrap": 0,
	"checkpoint": null,
}
	
func _physics_process(delta):
	if Input.is_action_just_pressed("pause") and __can_pause:
		get_tree().paused = !get_tree().paused
	
func set_check_point(vec):
	__has_check_point = true
	__saved_player_stats = __current_level.player_node.stats.get_data()
	update_player_save_data("checkpoint", vec)
	
func has_check_point():
	return __has_check_point
	
func update_player_save_data(key, value):
	__saved_player_stats[key] = value

# Deletes the current level (if one is active) and instances a new one from the specified
# scene.
func set_current_level(index):
	__level_intro_timer.start()
	__color_rect.visible =  true
	get_hud().hide_global_message()
	__has_check_point = false
	update_player_save_data("checkpoint", null)
	var level_scene: PackedScene = __level_list.get_level_scene(index)
	__level_index = index
	if __current_level != null:
		__saved_player_stats = __current_level.player_node.stats.get_data()
		__saved_player_stats["life"] = PlayerStats.MAX_HEALTH
		__saved_player_stats["checkpoint"] = null
		__current_level.queue_free()
	__current_level = level_scene.instance()
#	print(__current_level.name)
	__current_level.connect("ready", self, "_on_current_level_ready")
	add_child(__current_level)
	__current_level.set_player_stats(__saved_player_stats)
	__pauseability_timer.start()
	__can_pause = false
	
func set_current_to_next_level():
	if !__level_list.is_last_level(__level_index):
		set_current_level(__level_index + 1)
	else:
		__has_completed_game = true
		emit_signal("game_completed")
		visible = false
		__current_level.queue_free()
		__current_level = null
		
func reset_current_level():
	__color_rect.visible = false
	get_hud().hide_global_message()
	var level_scene: PackedScene = __level_list.get_level_scene(__level_index)
	__current_level.queue_free()
	__current_level = level_scene.instance()
	__current_level.connect("ready", self, "_on_current_level_ready")
	if has_check_point():
		__current_level.set_check_point_enabled(true)
	add_child(__current_level)
	__saved_player_stats["life"] = PlayerStats.MAX_HEALTH
	__current_level.set_player_stats(__saved_player_stats)
	__current_level.start()
	
func start_reset_sequence():
	__reset_timer.start()
	
func _on_current_level_ready():
	__hud.connect_to_player(__current_level.player_node)
	
func get_hud(): 
	return __hud
	
func start_transitioning_to_next_level():
	__next_level_transition_timer.start()

func _on_MainMenu_game_started():
	set_current_level(int(__has_completed_game))
	visible = true

func _on_PauseabilityTimer_timeout():
	__can_pause = true

func _on_LevelIntroTimer_timeout():
	__color_rect.visible = false
	__current_level.start()


func _on_LevelResetTimer_timeout():
	reset_current_level()


func _on_NextLevelTransitionTimer_timeout():
	set_current_to_next_level()
