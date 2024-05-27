extends "res://scenes/game/world/entity/MovingEntity.gd"
class_name Player

const PLAYER_TEAM = "player_team"
const RAM_SLIDE_SPEED = 200
const RAM_SLIDE_DAMAGE = 8

var __death_sound = preload("res://assets/audio/sfx/player/player_death.wav")

var air_acceleration = 250

var walk_transition_weight = .4
var max_walk_speed = 50
var walk_friction = .4

var dash_transition_weight = .05
var max_dash_speed  = 100
var dash_friction = .1

var jump_speed = 150
var min_jump_speed = 50

var max_crouch_speed = 15
var crouch_transition_weight = .3

var slide_speed = 180
var slide_friction = 0.02
var slide_mitigation_acceleration = 250


var moving_direction = 1
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

func _physics_process(delta):
	if position.y > 144 + 24:
		die()
		return
	set_ram_slide_hit_box_enabled(is_moving_faster_than(max_dash_speed))

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
	set_velocity_x(lerp(get_velocity().x, direction * max_dash_speed, dash_transition_weight))
	moving_direction = direction

func walk(direction: int, delta: float):
	set_velocity_x(lerp(get_velocity().x, direction * max_walk_speed, walk_transition_weight))
	moving_direction = direction

func sneak(direction: int, delta):
	set_velocity_x(lerp(get_velocity().x, direction * max_crouch_speed, crouch_transition_weight))
	moving_direction = direction
	
func air_move(direction: int, delta: float):
	accelerate_x(air_acceleration * direction, max_dash_speed, delta)
	moving_direction = direction
	
func negate_slide(direction: int, delta: float):
	accelerate_x(slide_mitigation_acceleration * direction, max_walk_speed, delta)
	moving_direction = direction
	
func apply_slide_friction(delta):
	set_velocity_x(lerp(get_velocity().x, 0, slide_friction))
	
func stop_running():
	set_velocity_x(lerp(get_velocity().x, 0, walk_friction))

func crouch_walk(direction: int, delta: float):
	pass

func slide(direction: int):
	set_velocity_x(direction * slide_speed)

func crouch():
	if __is_crouched: return
	__is_crouched = true
	__hit_box_shape.shape.extents.y = 3
	__hit_box_shape.position.y = 0
	
	
func stand_up():
	if !__is_crouched: return
	__is_crouched = false
	__hit_box_shape.shape.extents.y = 7
	__hit_box_shape.position.y = -4

func is_crouched():
	return __is_crouched

func jump():
	set_velocity_y(-jump_speed)
	
func is_effectively_standing_still():
	return int(round(get_velocity().x)) == 0

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
