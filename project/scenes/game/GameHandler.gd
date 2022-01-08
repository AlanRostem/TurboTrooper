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

onready var __cave_theme = preload("res://assets/audio/music/normal_theme.wav")
#onready var __cave_theme = preload("res://assets/audio/music/normal_theme.wav")
#onready var __cave_theme = preload("res://assets/audio/music/normal_theme.wav")
#onready var __cave_theme = preload("res://assets/audio/music/normal_theme.wav")


onready var __win_theme_player = $WinThemePlayer

var __current_level_theme
var __current_level_theme_enum

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
	__saved_player_stats["checkpoint"] = vec
	
func has_check_point():
	return __has_check_point

func set_current_to_next_level():
	if !__level_list.is_last_level(__level_index):
		change_level(__level_index + 1)
	else:
		__has_completed_game = true
		emit_signal("game_completed")
		visible = false
		__current_level.queue_free()
		__current_level = null
		__has_check_point = false

# Deletes the current level (if one is active) and instances a new one from the specified
# scene.
func set_current_level(index):
	var level_scene: PackedScene = __level_list.get_level_scene(index)
	__level_index = index
	if __current_level != null:
		__current_level.queue_free()
	__current_level = level_scene.instance()
	__current_level.connect("ready", self, "_on_current_level_ready")
	add_child(__current_level)
	__current_level.set_player_stats(__saved_player_stats)
	__load_current_level_theme(__current_level.get_theme_enum())
	__pauseability_timer.start()
	__can_pause = false

func change_level(index):
	__has_check_point = false
	if __current_level != null:
		__saved_player_stats = __current_level.player_node.stats.get_data()
	__saved_player_stats["checkpoint"] = null
	__saved_player_stats["life"] = PlayerStats.MAX_HEALTH
	set_current_level(index)
	
	__level_intro_timer.start()
	__color_rect.visible =  true
	get_hud().hide_global_message()

func reset_current_level():
	set_current_level(__level_index)
	if has_check_point():
		__current_level.set_check_point_enabled(true)

func start_reset_sequence(died = false):
	__reset_timer.start()
	if died:
		__current_level_theme.stop()
	
func __load_current_level_theme(theme_enum):
	if __current_level_theme_enum == theme_enum: return
	if __current_level_theme != null:
		__current_level_theme.queue_free()
		__current_level_theme = null
	__current_level_theme = AudioStreamPlayer.new()
	match theme_enum:
		Level.Theme.CAVE:
			__current_level_theme.stream = __cave_theme
	add_child(__current_level_theme)
	
func start_level_win_sequence():
	__current_level_theme.stop()
	__win_theme_player.play()

func _on_current_level_ready():
	__hud.connect_to_player(__current_level.player_node)
	
func get_hud(): 
	return __hud
	
func start_transitioning_to_next_level():
	__next_level_transition_timer.start()

func _on_MainMenu_game_started():
	change_level(int(__has_completed_game))
	visible = true

func _on_PauseabilityTimer_timeout():
	__can_pause = true

func _on_LevelIntroTimer_timeout():
	__color_rect.visible = false
	__current_level_theme.play()
	
func _on_LevelResetTimer_timeout():
	reset_current_level()
	__current_level_theme.play()

func _on_NextLevelTransitionTimer_timeout():
	set_current_to_next_level()
