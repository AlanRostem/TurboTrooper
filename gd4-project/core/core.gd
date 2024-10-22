extends Node2D
class_name Core

@export var __first_scene: PackedScene
var __current_scene: GameSection

func _ready() -> void:
	var sec: GameSection = __spawn_section(__first_scene)
	set_current_section(sec)
	
func __spawn_section(scene: PackedScene) -> GameSection:
	var sec: GameSection = scene.instantiate()
	add_child(sec)
	return sec
	
func set_current_section(sec: GameSection) -> void:
	if __current_scene != null:
		__current_scene.exited.emit()
		__current_scene.queue_free()
	__current_scene = sec
	__current_scene.entered.emit(self)
