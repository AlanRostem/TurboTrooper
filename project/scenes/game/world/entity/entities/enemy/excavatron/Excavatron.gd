extends Enemy

const SPEED = 60

func set_direction(dirvec:Vector2):
	set_velocity(dirvec*SPEED)
	var rot = Vector2.DOWN.angle_to(dirvec)
	$AnimatedSprite.rotation = rot

func _physics_process(delta):
	._physics_process(delta)
	if is_colliding():
		if state_machine.get_current_state() == "EnemyRamIntoAirState":
			die()
			return
		queue_free()
