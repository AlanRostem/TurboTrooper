extends MovingEntity

onready var __out_hit_box_shape = $OutHitBox/CollisionShape2D
onready var __body_shape = $BodyShape
onready var __disabled_timer = $DisabledTimer
onready var __sprite = $AnimatedSprite

const ANGLE_SPEED = PI * 2.0 / 3.0
const SPEED = 60

var __enabled = true
var __angle = 0

func _physics_process(delta):
	if !__enabled: return
	__angle += ANGLE_SPEED * delta
	set_velocity_y(sin(__angle) * SPEED)
	position.y += get_velocity().y * delta

func set_enabled(value):
	__body_shape.set_deferred("disabled", value)
	__out_hit_box_shape.set_deferred("disabled", !value)
	__enabled = value
	__sprite.animation = "default" if value else "disabled"

func _on_InHitBox_hit_received(hitbox, damage, damage_type):
	if damage_type == HealthComponent.DAMAGE_TYPE_ENERGY or damage_type == HealthComponent.DAMAGE_TYPE_CRITICAL:
		set_enabled(false)
		__disabled_timer.start()
		set_velocity_y(0)


func _on_DisabledTimer_timeout():
	set_enabled(true)
	
func _on_OutHitBox_hit_dealt(hitbox):
	var player = hitbox.get_parent()
	if player is Player:
		player.stats.take_one_damage()
