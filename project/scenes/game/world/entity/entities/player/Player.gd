extends "res://scenes/game/world/entity/MovingEntity.gd"
class_name Player

const PLAYER_TEAM = "player_team"
const RAM_SLIDE_SPEED = 200
const RAM_SLIDE_DAMAGE = 8

var __death_sound = preload("res://assets/audio/sfx/player/player_death.wav")

var can_swap_looking_direction = true

var __is_crouched = false

var __looking_vector = Vector2.RIGHT
var __horizontal_looking_direction = 1

var __can_move_on_ground = true
var __is_opening_crate = false

var __is_invincible = false
var __is_immortal = false
var __controls_enabled = true

onready var __hit_box_shape = $InHitBox/CollisionShape2D
onready var hit_box = $InHitBox
onready var state_machine = $PlayerFSM
onready var stats = $PlayerStats
onready var __sprite = $PlayerSprite

onready var __flashing_timer = $FlashingTimer
onready var __invincibility_timer = $InvincibilityTimer

onready var __ram_slide_hit_box = $RamSlideHitBox
onready var __ram_slide_hit_box_shape = $RamSlideHitBox/CollisionShape2D

onready var __crate_opening_timer = $CrateOpeningTimer

onready var __right_roof_ray = $RoofDetector/RightRay
onready var __left_roof_ray = $RoofDetector/LeftRay

onready var __camera = $Camera2D

func _ready():
	parent_world.get_parent().player_node = self
	gravity = PlayerSpeedValues.PLAYER_GRAVITY

func _physics_process(delta):
	if position.y > 144 + 24:
		die()
		return
	set_ram_slide_hit_box_enabled(is_moving_faster_than(PlayerSpeedValues.PLAYER_TOP_SPRINT_SPEED))

func set_camera_follow(value):
	__camera.current = value

func set_camera_bounds(bounds: Rect2):
	__camera.limit_left = clamp(bounds.position.x, 0, INF);
	__camera.limit_top = 0;
	__camera.limit_right = bounds.size.x + bounds.position.x;
	__camera.limit_bottom = 144;

func become_immortal():
	__is_immortal = true

func set_controls_enabled(value):
	__controls_enabled = value

func controls_enabled():
	return __controls_enabled

func run(direction: int, delta: float):
	if direction != 0:
		look_horizontally(direction)
	set_velocity_x(
		lerp(get_velocity().x, 
		direction * PlayerSpeedValues.PLAYER_TOP_SPRINT_SPEED, 
		PlayerSpeedValues.PLAYER_SPRINT_TRANSITION_WEIGHT))

func walk(direction: int, delta: float):
	if direction != 0:
		look_horizontally(direction)
	set_velocity_x(
		lerp(get_velocity().x, 
		direction * PlayerSpeedValues.PLAYER_WALK_SPEED, 
		PlayerSpeedValues.PLAYER_WALK_TRANSITION_WEIGHT))
	
func instant_move(direction: int, speed: float):
	if direction != 0:
		look_horizontally(direction)
	set_velocity_x(direction * speed)

func instant_stop():
	set_velocity_x(0)
	
func lose_momentum_on_landing(delta):
	set_velocity_x(sign(get_velocity().x) * PlayerSpeedValues.PLAYER_TOP_SPRINT_SPEED)
	
func resist_high_air_speed(direction: int, delta: float):
	if direction != 0:
		look_horizontally(direction)
	var factor = max(0.00001, abs(get_velocity().x / PlayerSpeedValues.PLAYER_TOP_SPRINT_SPEED))
	var time = factor * PlayerSpeedValues.PLAYER_DECELERATE_SPRINT_IN_AIR_BY_TURN_TIME
	decelerate_x((PlayerSpeedValues.PLAYER_TOP_SPRINT_SPEED - PlayerSpeedValues.PLAYER_WALK_SPEED) / time, delta)
	
func air_stop(delta: float):
	decelerate_x(PlayerSpeedValues.PLAYER_STOP_MID_AIR_DECELERATION, delta)
	
func negate_slide(delta: float):
	decelerate_x(PlayerSpeedValues.PLAYER_SLIDE_NEGATION_DECELERATION, delta)
	
func stop_running():
	set_velocity_x(lerp(get_velocity().x, 0, PlayerSpeedValues.PLAYER_WALK_FRICTION))

func slide(delta: float):
	decelerate_x(PlayerSpeedValues.PLAYER_SLIDE_DECELERATION, delta)
	# TODO: See if this works with slopes

func crouch():
	__is_crouched = true

func stand_up():
	__is_crouched = false

func is_standing_still():
	return abs(get_velocity().x) < PlayerSpeedValues.STOP_MARGIN

func is_crouched():
	return __is_crouched

func jump():
	set_velocity_y(-PlayerSpeedValues.PLAYER_MAX_JUMP_SPEED)
	
func is_effectively_standing_still():
	return int(round(get_velocity().x)) == 0
	
func is_moving_slower_than(speed: float):
	return abs(get_velocity().x) < speed

func is_on_ground():
	return is_on_floor()
	
func recoil_boost(speed):
	set_velocity_y(-speed)
	
func look_horizontally(dir):
	if __looking_vector.y == 0:
		__looking_vector.x = dir
	__horizontal_looking_direction = dir
	
func get_horizontal_looking_dir():
	return __horizontal_looking_direction
	
func set_aim_up(value):
	if value and !is_crouched():
		if __looking_vector.y == 0:
			__looking_vector.x = 0
			__looking_vector.y = -1
	else:
		__looking_vector.y = 0
		__looking_vector.x = __horizontal_looking_direction
	
func is_aiming_up():
	return __looking_vector.y < 0
	
func is_aiming_down():
	return __looking_vector.y > 0
	
func toggle_aim_down():
	if __looking_vector.y == 0:
		__looking_vector.y = 1
		__looking_vector.x = 0
	else:
		__looking_vector.y = 0
		__looking_vector.x = __horizontal_looking_direction
		
func stop_aiming_down():
	__looking_vector.x = __horizontal_looking_direction
	__looking_vector.y = 0
	
func get_looking_vector():
	return __looking_vector
	
func get_horizontal_looking_direction():
	return __horizontal_looking_direction
	
func set_sprite_frames(frames):
	var frame = __sprite.frame
	__sprite.frames = frames
	__sprite.frame = frame

func set_hit_box_enabled(value):
	__hit_box_shape.set_deferred("disabled", !value)
	
func start_invinvibility_sequence():
	become_invincible()
	__invincibility_timer.start()
	__flashing_timer.start()
	visible = false
	
func become_invincible():
	set_hit_box_enabled(false)
	__is_invincible = true
	
func is_invincible():
	return __is_invincible
	
func is_roof_above():
	return __right_roof_ray.is_colliding() or __left_roof_ray.is_colliding()
	
func is_opening_crate():
	return __is_opening_crate

func set_opening_crate(value):
	__is_opening_crate = value
	__can_move_on_ground = !value
	if value:
		__crate_opening_timer.start()

func set_ram_slide_hit_box_enabled(value):
	__ram_slide_hit_box_shape.set_deferred("disabled", !value)
	__ram_slide_hit_box.scale.x = sign(get_velocity().x)
	$MeteorEffectSprite.visible = value
	$MeteorEffectSprite.flip_h = __ram_slide_hit_box.scale.x < 0

func _on_FlashingTimer_timeout():
	visible = !visible
	
func set_can_move_on_ground(value):
	__can_move_on_ground = value

func can_move_on_ground():
	return __can_move_on_ground
	
func die():
	if __is_immortal: return
	state_machine.transition_to("PlayerDeathState")
	parent_world.get_parent_level().game_handler.start_reset_sequence(true)
	parent_world.hide_and_remove_entities()
	parent_world.play_sound(__death_sound)
	if stats.get_health() > PlayerStats.MAX_HEALTH:
		stats.set_health(stats.get_health() - 1)
	__is_immortal = true

func _on_InvincibilityTimer_timeout():
	set_hit_box_enabled(true)
	__flashing_timer.stop()
	visible = true
	__is_invincible = false

func _on_RamSlideHitBox_hit_dealt(hitbox):
	var damage_type = HealthComponent.DAMAGE_TYPE_RAM_SLIDE
	if stats.has_weapon():
		if stats.get_weapon().name == "Sword":
			damage_type = HealthComponent.DAMAGE_TYPE_MELEE
	hitbox.take_hit(__ram_slide_hit_box, RAM_SLIDE_DAMAGE, {
		"ram_slide": true
	}, damage_type)

func _on_CrateOpeningTimer_timeout():
	set_opening_crate(false)

func _on_PlayerStats_died():
	die()
