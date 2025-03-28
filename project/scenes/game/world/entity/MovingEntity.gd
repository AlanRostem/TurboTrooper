# Base class for moving entities. Its collision mode can be modified between 
# MOVE, SLIDE, and SNAP. Its velocity can be changed at any time but is only 
# registered in the next physics process call.

extends KinematicBody2D
class_name MovingEntity

enum CollisionModes {
	MOVE,
	SLIDE,
	SNAP
}

export(CollisionModes) var collision_mode

export var is_gravity_enabled = true
export var is_internal_collision_func_enabled = true

export var gravity = 400

export var stop_on_slope = true

export var __remove_when_entity_pool_cleared = true

var parent_world = null

var __velocity = Vector2()

var __down_vector = Vector2.DOWN
var __snap_vector = Vector2.DOWN

var __can_accelerate = true

var __is_on_slope = false
var __is_colliding = false

func _ready():
	if parent_world == null:
		parent_world = get_parent().get_parent()
		
func _process(delta):
	if __remove_when_entity_pool_cleared and parent_world.remove_all_entities():
		queue_free()
# Returns true if the absolute value of the entity's x-velocity is greater
# than the max_viable_x_speed export variable
func is_moving_too_fast(max_viable_x_speed):
	var margin = 0.1
	return abs(get_velocity().x) >= max_viable_x_speed + margin
	
func is_moving_faster_than(speed):
	var margin = 0.1
	return abs(get_velocity().x) > speed + margin
	
# TODO: Remove function
func is_moving_approximately_at_speed(max_viable_x_speed):
	var margin = 1
	return max_viable_x_speed - abs(get_velocity().x) <=  + margin

func is_moving_exactly_at_speed(speed: float):
	return speed - abs(get_velocity().x) < PlayerSpeedValues.STOP_MARGIN

func is_colliding():
	return __is_colliding

# Change where "down" points to relative to the entity. This affects how the 
# changing of velocity is done.
func set_down_vector(vector):
	__down_vector = vector
	__snap_vector = vector 

# Retrieve the velocity vector as perceived by the down vector
func get_velocity():
	return __velocity

# Change the velocity vector as perceived by the down vector
func set_velocity(velocity):
	if velocity.y < 0:
		__snap_vector = Vector2.ZERO
	__velocity = velocity

# Change the velocity on the x-axis vector as perceived by the down vector
func set_velocity_x(x):
	__velocity = Vector2(x, get_velocity().y)

# Change the velocity on the y-axis vector as perceived by the down vector. If
# the y-velocity is negative when the collision mode is SNAP, then the snap 
# vector is set to the zero-vector until the entity is on the floor again.
func set_velocity_y(y):
	if y < 0:
		__snap_vector = Vector2.ZERO
	__velocity = Vector2(get_velocity().x, y)
	
func accelerate_x(x, max_speed, delta):
	var cur_vel = get_velocity()
	set_velocity_x(clamp(cur_vel.x + x * delta, -max_speed, max_speed))
	
func decelerate_x(x, delta):
	var vx = get_velocity().x
	var movement = -sign(vx) * x * delta
	if sign(get_velocity().x) != sign(vx):
		set_velocity_x(0)
		return
	set_velocity_x(vx + movement)

func is_on_slope():
	return __is_on_slope

func _physics_process(delta):
	if is_gravity_enabled:
		__velocity += __down_vector * gravity * delta
	if !is_internal_collision_func_enabled: return
	match collision_mode:
		CollisionModes.MOVE:
			var coll: KinematicCollision2D = move_and_collide(__velocity * delta)
			__is_colliding = coll != null and coll.collider_id != 0
		CollisionModes.SLIDE:
			__velocity = move_and_slide(__velocity, -__down_vector)
		CollisionModes.SNAP:
			var vel = move_and_slide_with_snap(
				__velocity, __snap_vector * parent_world.get_tile_size() / 4,
				-__down_vector, stop_on_slope)
			if is_on_wall():
				__velocity = vel
			else:
				__velocity.y = vel.y
			if is_on_floor():
				__snap_vector = Vector2(__down_vector)
				__is_on_slope = get_floor_normal().y != -1
