extends "res://scenes/game/world/entity/entities/item/CollectibleItem.gd"

const MAX_FOLLOW_SPEED = 140
const FOLLOW_LERP_WEIGHT = .10
const MIN_FOLLOW_X_DIST = 16

onready var __body_shape = $BodyShape

onready var __arrow_sprite = $ArrowSprite

func _physics_process(delta):
	if !_collected: return
	var dir = parent_world.player_node.position - position
	var vel = dir.normalized() * MAX_FOLLOW_SPEED
	var prev = get_velocity()
	if abs(dir.x) > MIN_FOLLOW_X_DIST:
		set_velocity_x(lerp(prev.x, vel.x, FOLLOW_LERP_WEIGHT))
	elif abs(dir.x) < MIN_FOLLOW_X_DIST - 2:
		set_velocity_x(lerp(prev.x, 0, FOLLOW_LERP_WEIGHT))
	set_velocity_y(lerp(prev.y, vel.y, FOLLOW_LERP_WEIGHT))

func _player_collected(player):
	set_attached_to_player(true)
		
func set_attached_to_player(value):
	_collected = value
	__body_shape.disabled = value
	is_gravity_enabled = !value
	__arrow_sprite.visible = !value
