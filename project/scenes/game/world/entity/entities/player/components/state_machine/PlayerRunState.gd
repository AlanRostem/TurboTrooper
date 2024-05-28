extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

var __dust_trail_scene = preload("res://scenes/game/world/other/DustTrailEffect.tscn")

onready var __dust_spawn_timer = $DustSpawnTimer
onready var __slide_sound = $SlideSound

var __spawning_dust = false

func movement_update(delta):
	if jump:
		parent_state_machine.transition_to("PlayerJumpState")
		return
	
	if !player.is_on_ground():
		parent_state_machine.transition_to("PlayerFallState")
		return
	
	if crouch:
		parent_state_machine.transition_to("PlayerSlideState")
		if player.stats.get_rush_energy() > 0 and player.is_moving_exactly_at_speed(PlayerSpeedValues.PLAYER_TOP_SPRINT_SPEED):
			player.set_velocity_x(sign(player.get_velocity().x)*PlayerSpeedValues.PLAYER_TURBO_SLIDE_SPEED)
			player.stats.use_rush_energy(2)
			__slide_sound.play()
		return
		
	var dir = int(move_right) - int(move_left)
	if dir != sign(player.get_velocity().x):
		player.stop_running()
		if player.is_moving_slower_than(PlayerSpeedValues.PLAYER_WALK_SPEED):
			parent_state_machine.transition_to("PlayerWalkState")
			return
	
	player.run(dir, delta)
	if not __spawning_dust:
		__spawning_dust = true
		__dust_spawn_timer.start()
	
func exit():
	__spawning_dust = false
	__dust_spawn_timer.stop()

func _on_DustSpawnTimer_timeout():
	player.parent_world.show_effect_deferred(__dust_trail_scene, player.position)
