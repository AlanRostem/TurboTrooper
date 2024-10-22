extends GameSection

var __current_level: LDTKLevel
@onready var __sub_viewport: SubViewport = $SubViewportContainer/SubViewport


func _on_entered(core: Core) -> void:
	var scene: PackedScene = load("res://assets/ldtk/levels/Level_0.scn")
	var level: LDTKLevel = __spawn_level(scene)
	set_current_level(level)
	
func __spawn_level(scene: PackedScene) -> LDTKLevel:
	var level: LDTKLevel = scene.instantiate()
	__sub_viewport.add_child(level)
	return level
	
func set_current_level(level: LDTKLevel) -> void:
	if __current_level != null:
		__current_level.queue_free()
	__current_level = level
