extends "res://scenes/game/world/entity/entities/enemy/rush_rogue/state_machine/RushRogueState.gd"

func physics_update(delta):
	if rush_rogue.is_on_wall() and rush_rogue.can_see_player():
		parent_state_machine.transition_to("RushRogueChargeUpState")
	
func enter(message: Dictionary):
	rush_rogue.set_velocity_x(rush_rogue.get_horizontal_player_detect_direction() * MAX_RUSH_SPEED)

func _on_RushRogue_player_visual_lost(player):
	parent_state_machine.transition_to("RushRoguePatrolState")
	rush_rogue.horizontal_looking_direction = rush_rogue.get_horizontal_player_detect_direction()
