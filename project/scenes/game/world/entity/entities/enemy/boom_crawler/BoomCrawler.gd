extends Enemy

const WALK_SPEED = 30

export var __direction = -1

func _ready():
	set_velocity_x(__direction * WALK_SPEED)

func _physics_process(delta):
	if is_on_wall():
		set_velocity_x(-get_velocity().x)


func _on_OutHitBox_hit_dealt_then_destroy_self(hitbox):
	queue_free()
	# TODO: Spawn explosion effect
