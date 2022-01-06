extends "res://scenes/game/level/Level.gd"

const MAX_SECRET_SCORE = 10000

onready var __bomb_switch = $GameWorld/Geometry/BombSwitch

onready var __blockade_shape = $GameWorld/EscapeArea/Blockade/CollisionShape2D

onready var __arrow_sprite = $GameWorld/EscapeArea/ArrowSprite
onready var __secret_arrow_sprite = $GameWorld/SecretEscapePoint/ArrowSprite

var __touched_escape_area = false

func _ready():
	if game_handler.has_check_point():
		__blockade_shape.set_deferred("disabled", false)
		__touched_escape_area = true
	game_handler.get_hud().hide_global_message()
	__arrow_sprite.visible = false

func _on_EscapeArea_body_entered(player):
	if !__touched_escape_area:
		__touched_escape_area = true
		__blockade_shape.set_deferred("disabled", false)
	elif __bomb_switch.is_ticking():
		player.state_machine.transition_to("PlayerLeaveLevelState")
		__bomb_switch.complete()
		__arrow_sprite.visible = false
		stop_theme()

func _on_BombSwitch_activated():
	__arrow_sprite.visible = true
	__blockade_shape.set_deferred("disabled", true)

func _on_BombSwitch_completion_transition_over():
	start_player_scrap_to_score_conversion()

func _on_BombSwitch_detonated():
	player_node.die()

func _on_SecretEscapePoint_body_entered(player):
	player.state_machine.transition_to("PlayerLeaveLevelSecretState")
	__bomb_switch.complete()
	__arrow_sprite.visible = false
	stop_theme()
	__secret_arrow_sprite.visible = false
	var world = player.parent_world
	world.show_hover_text("+" + str(MAX_SECRET_SCORE) + "score", player.position)
	world.player_node.stats.add_score(MAX_SECRET_SCORE)
