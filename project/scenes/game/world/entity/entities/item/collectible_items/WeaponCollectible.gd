extends "res://scenes/game/world/entity/entities/item/CollectibleItem.gd"

export(PackedScene) var __weapon_scene

onready var __sprite = $Sprite

onready var __pick_up_timer = $PickUpAvailabilityTimer

onready var __detection_shape = $PlayerDetectionArea/BodyShape

var weapon

var __scrap_sound = preload("res://assets/audio/sfx/world/scrap/pick_up_scrap.wav")

export(String) var weapon_name
export(String) var weapon_name_to_display
export(int) var scrap_value 
export(int) var starting_ammo = 30

func _pick_up_condition(player):
	return true

func _player_collected(player):
	queue_free()
	if player.stats.has_weapon():
		if player.stats.get_weapon().name == weapon_name:
			player.stats.get_weapon().add_ammo(starting_ammo)
			parent_world.play_sound(__scrap_sound, 0.02) # TODO: Different sound
			parent_world.show_hover_text("+"+str(starting_ammo)+"ammo", position)
			return
	player.stats.instance_and_equip_weapon(__weapon_scene)
	player.stats.get_weapon().add_ammo(starting_ammo)
	parent_world.show_hover_weapon_collected(weapon_name_to_display, position)
	
func _physics_process(delta):
	set_velocity_y(lerp(get_velocity().y, 0, 0.1))
	
func set_sprite(sprite):
	__sprite.texture = sprite

func set_recently_dropped(value):
	if value:
		call_deferred("__set_life_timer_wait_time_to_low")
		
func __set_life_timer_wait_time_to_low():
	_life_timer.start(1.5)
	__pick_up_timer.start()
	__detection_shape.disabled = true

func _on_PickUpAvailabilityTimer_timeout():
	__detection_shape.disabled = false


func _on_ColorInversionTimer_timeout():
	$Sprite.use_parent_material = !$Sprite.use_parent_material 
