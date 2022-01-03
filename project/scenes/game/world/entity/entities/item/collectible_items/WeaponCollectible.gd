extends "res://scenes/game/world/entity/entities/item/CollectibleItem.gd"

export(PackedScene) var __weapon_scene

onready var __sprite = $Sprite

onready var __pick_up_timer = $PickUpAvailabilityTimer

onready var __detection_shape = $PlayerDetectionArea/BodyShape

var weapon

var __scrap_sound = preload("res://assets/audio/sfx/world/scrap/pick_up_scrap.wav")

export(String) var weapon_name 
export(int) var scrap_value 

func _pick_up_condition(player):
	if player.stats.has_weapon():
		if player.stats.get_weapon().name != weapon_name:
			return Input.is_action_just_pressed("aim_up")
	return true

func _player_collected(player):
	queue_free()
	if player.stats.has_weapon():
		if player.stats.get_weapon().name == weapon_name:
			player.stats.add_scrap(scrap_value)
			parent_world.play_sound(__scrap_sound, 0.02)
			parent_world.show_hover_scrap_collected(scrap_value, position + Vector2.UP * 16)
			return
	if weapon != null:
		player.stats.equip_weapon(weapon)
		parent_world.show_hover_weapon_collected(weapon.name, position)
		return
	player.stats.instance_and_equip_weapon(__weapon_scene)
	parent_world.show_hover_weapon_collected(player.stats.get_equipped_weapon().name, position)
	
func set_sprite(sprite):
	__sprite.texture = sprite

func set_recently_dropped(value):
	if value:
		call_deferred("__set_life_timer_wait_time_to_low")
		
func __set_life_timer_wait_time_to_low():
	_life_timer.start(3.5)
	__pick_up_timer.start()
	__detection_shape.disabled = true

func _on_PickUpAvailabilityTimer_timeout():
	__detection_shape.disabled = false
