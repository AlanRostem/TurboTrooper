extends "res://scenes/game/world/entity/entities/player/components/state_machine/PlayerState.gd"

onready var __move_timer = $MoveTimer

var __move = false

func enter(message):
	player.set_velocity_y(0)
	player.is_gravity_enabled = false
	__move_timer.start()
	call_deferred("__check_and_prevent_weapon_attack")
	
func __check_and_prevent_weapon_attack():
	if player.stats.has_weapon():
		player.stats.get_weapon().set_can_attack(false)


func exit():
	if player.stats.has_weapon():
		player.stats.get_weapon().set_can_attack(true)

func physics_update(delta):
	if !__move: return
	player.set_velocity_x(PlayerSpeedValues.PLAYER_TOP_SPRINT_SPEED * 1.5)
	if player.is_on_ground():
		parent_state_machine.transition_to("PlayerIdleState")
		player.set_velocity_x(0)


func _on_MoveTimer_timeout():
	__move = true
	player.is_gravity_enabled = true
