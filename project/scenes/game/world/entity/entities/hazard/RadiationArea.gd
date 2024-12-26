extends MovingEntity

var SPEED = PlayerSpeedValues.PLAYER_TOP_SPRINT_SPEED
const DIR = 1

func _ready():
	position.x += 216 * -DIR
	
	var timer = Timer.new()
	add_child(timer)
	timer.start(4)
	yield(timer, "timeout")
	timer.queue_free()
	
	set_velocity_x(SPEED * DIR)

func disable():
	$HitBox/BodyShape.set_deferred("disabled", true)

func _on_HitBox_hit_dealt(hitbox):
	set_velocity_x(0)
	hitbox.take_hit($HitBox, 1, {}, HealthComponent.DAMAGE_TYPE_INSTANT_DEATH)
