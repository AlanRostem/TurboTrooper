extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"


func movement_update(delta):
	# TODO: Coyote timer and jump buffer
	var dir = int(move_right) - int(move_left)
	if player.is_on_ground():
		player.stats.refill_rush_energy()
		if player.is_moving_faster_than(PlayerSpeedValues.PLAYER_TOP_SPRINT_SPEED):
			player.lose_momentum_on_landing(delta)
			parent_state_machine.transition_to("PlayerSlideState")
			return
		
		if player.is_moving_faster_than(PlayerSpeedValues.PLAYER_WALK_SPEED):
			parent_state_machine.transition_to("PlayerRunState")
			return
		
		if dir != 0:
			parent_state_machine.transition_to("PlayerWalkState")
			return
		
		parent_state_machine.transition_to("PlayerIdleState")
		return
		
	if player.is_moving_slower_than(PlayerSpeedValues.PLAYER_WALK_SPEED):
		if dir != 0:
			player.instant_move(dir, PlayerSpeedValues.PLAYER_WALK_SPEED)
		else:
			player.air_stop(delta)
		return
		
	if dir == -sign(player.get_velocity().x):
		player.resist_high_air_speed(dir, delta)
