extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

var __dust_trail_scene = preload("res://scenes/game/world/other/DustTrailEffect.tscn")

onready var __dust_spawn_timer = $DustSpawnTimer

var __spawning_dust = false

func movement_update(delta):
	if player.is_moving_too_fast(player.max_dash_speed):
		parent_state_machine.transition_to("PlayerSlideState")
		return
	
	if player.is_on_ground() and player.has_max_dash_charge() and player.stats.get_rush_energy() > 0:
		if !__spawning_dust:
			__dust_spawn_timer.start()
			__spawning_dust = true
	elif __spawning_dust:
		__spawning_dust = false
		__dust_spawn_timer.stop()
	
	if (move_left or move_right) and player.can_move_on_ground():
		var dir = int(move_right) - int(move_left)
		if dir != 0:
			player.look_horizontally(dir)
		player.run(dir, delta)
		
		var vel_x = player.get_velocity().x
		if sign(vel_x) != dir:
			player.reduce_dash_charge(delta)
		else:
			player.increase_dash_charge(delta)
	else:
		player.reduce_dash_charge(delta)
		player.stop_running()
		
	if !player.is_moving_too_fast(player.max_walk_speed):
		parent_state_machine.transition_to("PlayerWalkState")
		player.clear_dash_charge()
		return
			
	if crouch or slide_by_fire_button:
		if player.has_max_dash_charge() and player.stats.get_rush_energy() > 0:
			parent_state_machine.transition_to("PlayerSlideState", {
				"boost": true
			})
			player.clear_dash_charge()
		elif !slide_by_fire_button:
			parent_state_machine.transition_to("PlayerSlideState")

func exit():
	__spawning_dust = false
	__dust_spawn_timer.stop()

func _on_DustSpawnTimer_timeout():
	player.parent_world.show_effect_deferred(__dust_trail_scene, player.position)
