extends MovingEntity

const DAMAGE = 30

const BARREL_WIDTH = 5

const MAX_X_SPEED = 200
const MAX_LAUNCH_SPEED = 160
const MIN_LAUNCH_SPEED = 100

onready var __out_hit_box = $OutHitBox
onready var __sprite = $AnimatedSprite

func _ready():
	__sprite.frame = 0
	__sprite.play()

func _on_AnimatedSprite_animation_finished():
	queue_free()

func _on_OutHitBox_hit_dealt(hitbox):
	hitbox.take_hit(__out_hit_box, DAMAGE, {}, HealthComponent.DAMAGE_TYPE_EXPLOSIVE)

func _on_PlayerFlingArea_body_entered(player):
	var x_diff = player.position.x - position.x
	player.set_velocity_x(sign(x_diff) * MAX_X_SPEED)
	if abs(x_diff) < BARREL_WIDTH:
		player.set_velocity_y(-MAX_LAUNCH_SPEED)
	else:
		player.set_velocity_y(-MIN_LAUNCH_SPEED)
