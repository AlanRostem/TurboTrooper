extends "res://scenes/game/world/objective/Objective.gd"

signal activated()
signal detonated()

export var __detonation_time = 60

onready var __bomb_timer = $BombTimer

onready var __sprite  = $AnimatedSprite
onready var __arrow_sprite  = $ArrowSprite

onready var __body_shape = $StaticBody2D/CollisionShape2D
onready var __press_shape = $PressArea/CollisionShape2D

onready var __explode_sound = $ExplodeSound
onready var __press_sound = $PressSound

var __count_down = false

var __player_on_top = false

var __time_score = 0

func _physics_process(delta):
	if __count_down:
		__parent_level.game_handler.get_hud().set_global_message("ESCAPE! - " + str(round(__bomb_timer.time_left)))
	elif __player_on_top:
		__bomb_timer.start(__detonation_time)
		__count_down = true
		__sprite.animation = "on"
		__body_shape.set_deferred("disabled", true)
		__press_shape.set_deferred("disabled", true)
		__arrow_sprite.visible = false
		emit_signal("activated")
		if !get_parent_level().has_check_point():
			get_parent_level().save_check_point()
			
func connect_to_escape_area(escape_area):
	escape_area.connect("completed", self, "__on_escape_area_completed")
		
func __on_escape_area_completed():
	complete()
		
func set_detonation_time(time):
	__detonation_time = time
		
func get_time_score():
	return __time_score
		
func _on_PressArea_body_entered(body):
	__player_on_top = true
	__press_sound.play()
	__parent_level.play_battle_theme()
	
func is_ticking():
	return __count_down
	
func stop_ticking():
	__time_score = round(__bomb_timer.time_left) * 100
	__bomb_timer.stop()
	__parent_level.game_handler.get_hud().hide_global_message()
	__count_down = false

# TODO: Show explosion and die
func _on_BombTimer_timeout():
	emit_signal("detonated")
	__parent_level.stop_battle_theme()
	__parent_level.game_handler.get_hud().hide_global_message()
	__count_down = false
	__explode_sound.play()

func _on_BombSwitch_completed():
	stop_ticking()
	var world = __parent_level
	world.show_hover_text("+" + str(__time_score) + "score", world.player_node.position)
	world.player_node.stats.add_score(__time_score)

func _on_PressArea_body_exited(body):
	__player_on_top = false
