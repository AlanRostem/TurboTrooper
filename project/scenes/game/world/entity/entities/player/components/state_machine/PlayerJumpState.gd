extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

#var __is_jumping = false

onready var __jump_sound = $JumpSound

func movement_update(delta):
	if player.get_velocity().y > 0:
		parent_state_machine.transition_to("PlayerFallState")
		return
		
	if !jump:
		if player.get_velocity().y < -PlayerSpeedValues.PLAYER_MIN_JUMP_SPEED:
			player.set_velocity_y(-PlayerSpeedValues.PLAYER_MIN_JUMP_SPEED)
		parent_state_machine.transition_to("PlayerFallState")
		return
		
	var dir = int(move_right) - int(move_left)
	if player.is_moving_slower_than(PlayerSpeedValues.PLAYER_WALK_SPEED):
		if dir != 0:
			player.instant_move(dir, PlayerSpeedValues.PLAYER_WALK_SPEED)
		else:
			player.air_stop(delta)
		return
		
	if dir == -sign(player.get_velocity().x):
		player.resist_high_air_speed(dir, delta)

func enter(message: Dictionary):
#	if message.has("jumping"):
#		__is_jumping = true
	player.jump()
	
	__jump_sound.play()
#	player.crouch()
#
#func exit():
#	__is_jumping = false
