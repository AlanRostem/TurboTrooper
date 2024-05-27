extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

func enter(message):
	pass # TODO: jump buffer

func movement_update(delta):
	if !player.is_on_ground():
		parent_state_machine.transition_to("PlayerAirborneState")
		return
	
	if jump:
		parent_state_machine.transition_to("PlayerAirborneState", {
			"jumping": true
		})
		return
		
	if crouch:
		if !player.is_effectively_standing_still():
			parent_state_machine.transition_to("PlayerSlideState")
			return
		parent_state_machine.transition_to("PlayerCrouchState")
		return
		
	if (move_left or move_right):
		var dir = int(move_right) - int(move_left)
		if dir != 0:
			player.look_horizontally(dir)
		player.walk(dir, delta)

		if player.is_moving_approximately_at_speed(player.max_walk_speed):
			parent_state_machine.transition_to("PlayerRunState")
		return
		
	parent_state_machine.transition_to("PlayerIdleState")
