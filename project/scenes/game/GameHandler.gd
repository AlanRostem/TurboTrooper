extends Node2D


# Handles everything related to playing the game itself. This node swaps out levels when
# transitioning between them and handles the level selection world. This node also loads
# all save data about the player and manages the player's temporary in-game stats. With
# that in mind, all user interface, such as the pause menu and HUD, will be handled through
# the playable nodes themselves (such as a level and the level select world)

var __current_level = null

var __level_index = -1

onready var __hud = $CanvasLayer/HUD

onready var __level_list = $LevelList

var __has_check_point = false

var __saved_player_stats = {
	"score": 0,
	"life": 3,
	"weapon": -1,
	"scrap": 0,
	"checkpoint": null,
}

func _ready():
	set_current_level(0)
	
func set_check_point(vec):
	__has_check_point = true
	update_player_save_data("checkpoint", vec)

func has_check_point():
	return __has_check_point
	
func update_player_save_data(key, value):
	__saved_player_stats[key] = value

# Deletes the current level (if one is active) and instances a new one from the specified
# scene.
func set_current_level(index):
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
	__current_level.connect("ready", self, "_on_current_level_ready")
	add_child(__current_level)
	__current_level.set_player_stats(__saved_player_stats)
	
func set_current_to_next_level():
	if !__level_list.is_last_level(__level_index):
		set_current_level(__level_index + 1)
		
func reset_current_level():
	var level_scene: PackedScene = __level_list.get_level_scene(__level_index)
	if __has_check_point:
		__saved_player_stats = __current_level.player_node.stats.get_data()
	__current_level.queue_free()
	__current_level = level_scene.instance()
	__current_level.connect("ready", self, "_on_current_level_ready")
	add_child(__current_level)
	__current_level.set_player_stats(__saved_player_stats)
	
func _on_current_level_ready():
	__hud.connect_to_player(__current_level.player_node)
	
func get_hud(): 
	return __hud
