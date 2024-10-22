extends Node2D
class_name CharacterEntity

signal spawned(level: LDTKLevel, data: Dictionary)
signal despawned(data: Dictionary)

var __level: LDTKLevel
var __is_despawned: bool

func init_spawn(level: LDTKLevel, data: Dictionary) -> void:
	spawned.emit(level, data)
	__level = level

func despawn(data: Dictionary = {}) -> void:
	if __is_despawned:
		return
	__is_despawned = true
	despawned.emit(data)
	queue_free()

func get_level() -> LDTKLevel:
	return __level
