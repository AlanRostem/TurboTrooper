extends Node2D

signal spawned_entity(entity)

export var __scene: PackedScene
export var __spawn_interval = 3
export var __player_detection_range_in_tiles = 24

var parent_world
var __is_player_seen = false

func _physics_process(delta):
	var player = parent_world.player_node
	if player == null: return
	var diff = player.position.x - position.x
	if abs(diff) < __player_detection_range_in_tiles * 8:
		if !__is_player_seen:
			__is_player_seen = true
			$Timer.start(__spawn_interval)
	elif __is_player_seen:
		__is_player_seen = false
		$Timer.stop()

func _on_Timer_timeout():
	var entity = parent_world.spawn_entity(__scene, position+$SpawnPoint.position)
	emit_signal("spawned_entity", entity)
