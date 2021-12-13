extends "res://scenes/game/world/entity/entities/enemy/rush_rogue/state_machine/RushRogueState.gd"

onready var __rush_timer = $RushTimer

func physics_update(delta):
	rush_rogue.horizontal_looking_direction = rush_rogue.get_horizontal_player_detect_direction()

func enter(message: Dictionary):
	rush_rogue.set_velocity_x(0)
	__rush_timer.start()
	
func exit():
	__rush_timer.stop()
	
func _on_RushRogue_player_detected(player):
	parent_state_machine.transition_to(name)

func _on_RushTimer_timeout():
	parent_state_machine.transition_to("RushRogueRushState")
