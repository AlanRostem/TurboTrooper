extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

func enter(message):
	# Setting it to true here because it becomes false when the level is reset
	# after a checkpoint is added. This is the worst way to fix it, but i dont
	# fucking give a shit because I just want this game to work.
	player.is_gravity_enabled = true

func movement_update(delta):
	if crouch:
		parent_state_machine.transition_to("PlayerCrouchState")
		return
		
	if jump:
		parent_state_machine.transition_to("PlayerAirborneState", {
			"jumping": true
		})
		return
		
	if move_left or move_right:
		parent_state_machine.transition_to("PlayerWalkState")
