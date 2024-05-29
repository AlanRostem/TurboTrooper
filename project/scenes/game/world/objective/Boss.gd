extends "res://scenes/game/world/objective/Objective.gd"


const CAMERA_MOVE_SPEED = 100

const CANNON_BALL_SPEED = 70

var __rocket_rogue_scene = preload("res://scenes/game/world/objective/RocketRogueForBoss.tscn")
var __cannon_ball_scene = preload("res://scenes/game/world/entity/entities/projectile/projectiles/CannonBall.tscn")
var __explosion_effect = preload("res://scenes/game/world/other/RocketRogueExplosionEffect.tscn")

onready var __rocket_rogue_spawn_timer = $RocketRogueSpawnTimer
onready var __cannon_timer = $CannonTimer
onready var __damage_flash_timer = $DamageFlashTimer
onready var __explosion_effect_timer = $ExplosionEffectTimer

onready var __spawn_pos_left = $SpawnPosLeft
onready var __spawn_pos_right = $SpawnPosRight

onready var __turret_pos_left = $TurretPosLeft
onready var __turret_pos_right = $TurretPosRight

onready var __health_component = $HealthComponent
onready var __blockade_shape = $Blockade/CollisionShape2D
onready var __camera = $Camera2D

onready var __check_point = $CheckPoint
onready var __eye_sprite = $EyeSprite

var __spawn_left = false
var __shoot_left = false
var __move_camera  = false
var __took_damage  = false
var __died  = false
var __explosion_count = 0

func _ready():
	get_parent_level().call_deferred("set_check_point_location", position + __check_point.position)

func _physics_process(delta):
	if __died:
		__eye_sprite.animation = "dead"
		return
	if __took_damage:
		__eye_sprite.animation = "take_damage"
		return
	
	var dist = get_parent_level().player_node.position.x
	dist -= position.x + __eye_sprite.position.x
	var max_dist = 4 * 8
	if abs(dist) < max_dist:
		__eye_sprite.animation = "watch_mid"
	else:
		if sign(dist) < 0:
			__eye_sprite.animation = "watch_left"
		else:
			__eye_sprite.animation = "watch_right"
	
	if !__move_camera: return
	__camera.position.x += CAMERA_MOVE_SPEED * delta
	if __camera.position.x > 80 + 4:
		__camera.position.x = 80 + 4
		__move_camera = false

func start_attack_sequence():
	__rocket_rogue_spawn_timer.start()
	__cannon_timer.start()

func _on_HealthComponent_health_depleted(health_left):
	complete()
	__rocket_rogue_spawn_timer.stop()
	__died = true
	__explosion_effect_timer.start()

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
	__took_damage = true
	__damage_flash_timer.start()

func _on_EnterArea_body_entered(player):
	if !__blockade_shape.disabled: return
	__blockade_shape.set_deferred("disabled", false)
	start_attack_sequence()
	get_parent_level().play_battle_theme()
	
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


func _on_DamageFlashTimer_timeout():
	__took_damage = false


func _on_ExplosionEffectTimer_timeout():
	var pos = position + __eye_sprite.position
	randomize()
	pos += Vector2(rand_range(-10, 10), rand_range(-10, 10))
	get_parent_level().get_game_world().show_effect_deferred(__explosion_effect, pos)
	__explosion_count += 1
	if __explosion_count == 10:
		__explosion_effect_timer.stop()
