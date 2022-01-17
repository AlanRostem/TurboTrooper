extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

const MIN_SLIDE_UNDER_ROOF_SPEED = 55

func movement_update(delta):
	if player.is_roof_above(): 
		if !player.is_moving_too_fast(MIN_SLIDE_UNDER_ROOF_SPEED):
			player.set_velocity_x(MIN_SLIDE_UNDER_ROOF_SPEED * player.get_looking_vector().x)
			if player.is_on_wall():
				player.look_horizontally(-player.get_looking_vector().x)
		return
		
	player.apply_slide_friction(delta)

	if player.is_effectively_standing_still():
		player.set_velocity_x(0)
		
	if player.is_on_slope():
		parent_state_machine.transition_to("PlayerSlideState")
			

	var dir = int(move_right) - int(move_left)
	if dir != 0:
		player.look_horizontally(dir)
	
	if jump and player.is_on_ground():
		parent_state_machine.transition_to("PlayerAirborneState", {
			"jumping": true
		})
		return

	if !crouch:
		if player.is_effectively_standing_still():
			parent_state_machine.transition_to("PlayerIdleState")
		else:
			parent_state_machine.transition_to("PlayerRunState")

func enter(message):
	player.crouch()
	player.collision_mode = MovingEntity.CollisionModes.SLIDE
	
func exit():
	player.stand_up()
	player.collision_mode = MovingEntity.CollisionModes.SNAP
