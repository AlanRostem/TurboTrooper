extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

func enter(message):
	pass # TODO: jump buffer

func movement_update(delta):
	if !player.is_on_ground():
		parent_state_machine.transition_to("PlayerAirBorneState")
		return
	
	if jump:
		parent_state_machine.transition_to("PlayerAirBorneState", {
			"jumping": true
		})
		return
		
	if crouch:
		parent_state_machine.transition_to("PlayerSlideState")
		return
		
	if (move_left or move_right):
		var dir = int(move_right) - int(move_left)

		player.walk(dir, delta)

		if player.is_moving_exactly_at_speed(PlayerSpeedValues.PLAYER_WALK_SPEED):
			parent_state_machine.transition_to("PlayerRunState")
		return
		
	parent_state_machine.transition_to("PlayerIdleState")
