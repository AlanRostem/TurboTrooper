extends MovingEntity

onready var __flash_timer = $FlashTimer
onready var _life_timer = $LifeTimer

var __flashing = false

var __player_found = null

var _collected = false

var __can_collect = true

export var __disappear_on_pickup = true
export var __disappear_on_timeout = true

onready var __life_timer = $LifeTimer

func _ready():
	if __disappear_on_timeout:
		__life_timer.start()

func _process(delta):
	if __disappear_on_timeout and _life_timer.time_left < _life_timer.wait_time / 2 and !__flashing:
		__flash_timer.start()
		__flashing = true
		
	if __player_found != null and __can_collect:
		if _pick_up_condition(__player_found) and !_collected:
			_collected = true
			_player_collected(__player_found)
			if __disappear_on_pickup:
				queue_free()
		
func _physics_process(delta):
	if is_on_floor():
		set_velocity_x(0)
		
func set_can_collect(value):
	__can_collect = value

func _player_collected(player):
	pass
	
func _pick_up_condition(player):
	return true

func _on_PlayerDetectionArea_body_entered(body):
	__player_found = body

func _on_LifeTimer_timeout():
	queue_free()

func _on_FlashTimer_timeout():
	visible = !visible
