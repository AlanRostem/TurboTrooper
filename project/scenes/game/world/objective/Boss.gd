extends "res://scenes/game/world/objective/Objective.gd"

var __rocket_rogue_scene = preload("res://scenes/game/world/objective/RocketRogueForBoss.tscn")

onready var __rocket_rogue_spawn_timer = $RocketRogueSpawnTimer
onready var __spawn_pos_left = $SpawnPosLeft
onready var __spawn_pos_right = $SpawnPosRight

var __spawn_left = true

func _ready():
	start_attack_sequence()

func start_attack_sequence():
	__rocket_rogue_spawn_timer.start()

func _on_HealthComponent_health_depleted(health_left):
	complete()


func _on_RocketRogueSpawnTimer_timeout():
	if __spawn_left:
		__spawn_left = false
		var rogue = get_parent_level().get_game_world().spawn_entity(__rocket_rogue_scene, __spawn_pos_left.global_position)
		rogue.horizontal_looking_direction = 1
	else:
		__spawn_left = true
		var rogue = get_parent_level().get_game_world().spawn_entity(__rocket_rogue_scene, __spawn_pos_right.global_position)
		rogue.horizontal_looking_direction = -1
