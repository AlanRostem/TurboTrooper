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

var __player_save_data = {
	"score": 0,
	"life": 0,
	"weapon": 0,
	"level": 0,
}

func _ready():
	set_current_level(0)
	
func update_player_save_data(key, value):
	__player_save_data[key] = value

# Deletes the current level (if one is active) and instances a new one from the specified
# scene.
func set_current_level(index):
	var level_scene = __level_list.get_level_scene(0)
	__level_index = index
	if __current_level != null:
		__current_level.queue_free()
	__current_level = level_scene.instance()
	__current_level.connect("ready", self, "_on_current_level_ready")
	add_child(__current_level)
	
func set_current_to_next_level():
	if !__level_list.is_last_level(__level_index):
		set_current_level(__level_index + 1)
	
func _on_current_level_ready():
	__hud.connect_to_player(__current_level.player_node)
	
func get_hud(): 
	return __hud
