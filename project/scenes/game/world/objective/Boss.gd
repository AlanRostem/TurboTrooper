extends "res://scenes/game/world/objective/Objective.gd"


const CAMERA_MOVE_SPEED = 100

const CANNON_BALL_SPEED = 70

var __rocket_rogue_scene = preload("res://scenes/game/world/objective/RocketRogueForBoss.tscn")
var __cannon_ball_scene = preload("res://scenes/game/world/entity/entities/projectile/projectiles/CannonBall.tscn")

onready var __rocket_rogue_spawn_timer = $RocketRogueSpawnTimer
onready var __cannon_timer = $CannonTimer

onready var __spawn_pos_left = $SpawnPosLeft
onready var __spawn_pos_right = $SpawnPosRight

onready var __turret_pos_left = $TurretPosLeft
onready var __turret_pos_right = $TurretPosRight

onready var __health_component = $HealthComponent
onready var __blockade_shape = $Blockade/CollisionShape2D
onready var __camera = $Camera2D

onready var __check_point = $CheckPoint

var __spawn_left = false
var __shoot_left = false
var __move_camera  = false

func _ready():
	get_parent_level().call_deferred("set_check_point_location", position + __check_point.position)

func _physics_process(delta):
	if !__move_camera: return
	__camera.position.x += CAMERA_MOVE_SPEED * delta
	if __camera.position.x > 80:
		__camera.position.x = 80
		__move_camera = false

func start_attack_sequence():
	__rocket_rogue_spawn_timer.start()
	__cannon_timer.start()

func _on_HealthComponent_health_depleted(health_left):
	complete()
	__rocket_rogue_spawn_timer.stop()

func _on_RocketRogueSpawnTimer_timeout():
	if __spawn_left:
		__spawn_left = false
		var rogue = get_parent_level().get_game_world().spawn_entity(__rocket_rogue_scene, position + __spawn_pos_left.position)
		rogue.horizontal_looking_direction = 1
	else:
		__spawn_left = true
		var rogue = get_parent_level().get_game_world().spawn_entity(__rocket_rogue_scene, position + __spawn_pos_right.position)
		rogue.horizontal_looking_direction = -1

func _on_HitBox_hit_received(hitbox, damage, damage_type):
	__health_component.take_damage(damage)

func _on_EnterArea_body_entered(player):
	if !__blockade_shape.disabled: return
	__blockade_shape.set_deferred("disabled", false)
	start_attack_sequence()
	player.set_camera_follow(false)
	__camera.current = true
	__camera.position.x = position.x - player.position.x
	__move_camera = true
	if !get_parent_level().game_handler.has_check_point():
		get_parent_level().save_check_point()

func _on_CannonTimer_timeout():
	if __shoot_left:
		__shoot_left = false
		var ball = get_parent_level().get_game_world().spawn_entity(__cannon_ball_scene, position + __turret_pos_left.position)
		ball.set_velocity(Vector2(CANNON_BALL_SPEED, CANNON_BALL_SPEED))
	else:
		__shoot_left = true
		var ball = get_parent_level().get_game_world().spawn_entity(__cannon_ball_scene, position + __turret_pos_right.position)
		ball.set_velocity(Vector2(-CANNON_BALL_SPEED, CANNON_BALL_SPEED))
