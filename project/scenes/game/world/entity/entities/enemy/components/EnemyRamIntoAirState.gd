extends "res://scenes/game/world/entity/entities/enemy/components/EnemyState.gd"

onready var __airborne_stun_timer = $AirborneStunTimer

export var __disable_gravity = false

func enter(message: Dictionary):
	if __disable_gravity:
		enemy.is_gravity_enabled = false
	else:
		__airborne_stun_timer.start()
		enemy.set_can_deal_damage(false)
	enemy.set_velocity_x(0)
	enemy.set_velocity_y(-Player.RAM_SLIDE_SPEED)
	
func exit():
	enemy.set_can_deal_damage(true)
	
func _on_AirborneStunTimer_timeout():
	parent_state_machine.transition_to(parent_state_machine.get_initial_state())
