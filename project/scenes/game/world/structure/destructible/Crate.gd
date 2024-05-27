extends "res://scenes/game/world/structure/DestructibleStructure.gd"

var __break_effect_scene = preload("res://scenes/game/world/other/CrateBreakEffect.tscn")

export(PackedScene) var __containment_scene

export(AudioStream) var __break_sound

var __collectible

func _destroyed():
	__collectible = parent_world.spawn_entity_deferred(__containment_scene, position)
	parent_world.show_effect_deferred(__break_effect_scene, position)
	parent_world.play_sound(__break_sound, 0.02)

func _on_InHitBox_received_additional_message(message):
	if message.has("ram_slide"):
		call_deferred("__set_collectible_y_speed")
		
func __set_collectible_y_speed():
	if __collectible == null: return
	__collectible.set_velocity_y(-Player.RAM_SLIDE_SPEED)
