extends "res://scenes/game/world/objective/Objective.gd"

signal activated()

export var __detonation_time = 60

onready var __bomb_timer = $BombTimer

onready var __sprite  = $AnimatedSprite
onready var __arrow_sprite  = $ArrowSprite

onready var __body_shape = $StaticBody2D/CollisionShape2D
onready var __press_shape = $PressArea/CollisionShape2D

var __count_down = false

func _physics_process(delta):
	if __count_down:
		__parent_level.game_handler.get_hud().set_global_message("ESCAPE! - " + str(round(__bomb_timer.time_left)))
		
func _on_PressArea_body_entered(body):
	__bomb_timer.start(__detonation_time)
	__count_down = true
	__sprite.animation = "on"
	__body_shape.set_deferred("disabled", true)
	__press_shape.set_deferred("disabled", true)
	__arrow_sprite.visible = false
	emit_signal("activated")
	
func is_ticking():
	return __count_down

# TODO: Show explosion and die
func _on_BombTimer_timeout():
	pass # Replace with function body.
