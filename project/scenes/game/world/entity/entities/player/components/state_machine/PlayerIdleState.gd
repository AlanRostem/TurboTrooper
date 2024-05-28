extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

func enter(message):
	# Setting it to true here because it becomes false when the level is reset
	# after a checkpoint is added. This is the worst way to fix it, but i dont
	# fucking give a shit because I just want this game to work.
	player.is_gravity_enabled = true
	player.set_velocity_x(0)
	
func movement_update(delta):
	if jump:
		parent_state_machine.transition_to("PlayerJumpState")
		return
	
	if !player.is_on_ground():
		parent_state_machine.transition_to("PlayerFallState")
		return
		
	if move_left or move_right:
		parent_state_machine.transition_to("PlayerWalkState")
		
	if crouch:
		parent_state_machine.transition_to("PlayerCrouchState")
		return
