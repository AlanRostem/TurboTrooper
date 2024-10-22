extends Node2D

signal owner_spawned(data:Dictionary)
signal owner_despawned(data:Dictionary)

var __level: LDTKLevel 
var __owner: Node2D

func _ready() -> void:
	get_parent().spawned.connect(__on_owner_spawn)
	get_parent().despawned.connect(__on_owner_despawn)
	__owner = get_parent()

func __on_owner_spawn(world:LDTKLevel, data:Dictionary) -> void:
	__level = world
	owner_spawned.emit(data)

func __on_owner_despawn(data:Dictionary) -> void:
	owner_despawned.emit(data)

func get_level() -> LDTKLevel:
	return __level

func get_owner_as_node2d() -> Node2D:
	return __owner
