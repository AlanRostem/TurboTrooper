extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

func enter(message):
	player.crouch()
	player.collision_mode = MovingEntity.CollisionModes.SLIDE
	
func exit():
	player.stand_up()
	player.collision_mode = MovingEntity.CollisionModes.SNAP
	#player.set_ram_slide_hit_box_enabled(false)

func movement_update(delta):
	if jump:
		parent_state_machine.transition_to("PlayerJumpState")
		return
	
	if !player.is_on_ground():
		parent_state_machine.transition_to("PlayerFallState")
		return
		
	var dir = int(move_right) - int(move_left)
	if dir == -sign(player.get_velocity().x) and !player.is_on_slope() or !crouch:
		player.negate_slide(delta)
	else:
		player.slide(delta)

	if crouch:
		return

	if player.is_standing_still():
		parent_state_machine.transition_to("PlayerIdleState")
		return
		
	if player.is_moving_slower_than(PlayerSpeedValues.PLAYER_WALK_SPEED):
		parent_state_machine.transition_to("PlayerWalkState")
		return
		
	var is_sliding_down_slope = player.is_on_slope() and player.get_velocity().y > 0
	if is_sliding_down_slope:
		parent_state_machine.transition_to("PlayerRunState")
