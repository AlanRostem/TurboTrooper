extends Node2D

signal attacked()
signal attack_cycle_end()
signal downwards_attack()
signal dropped()

export(SpriteFrames) var __player_sprite_frames
export(Texture) var __collectible_sprite
export(bool) var is_ammo_infinite = false
export(int) var ammo = 30

export(bool) var use_attacking_delay = true

var __collectible_scene = preload("res://scenes/game/world/entity/entities/item/collectible_items/WeaponCollectible.tscn")

var __pick_up_sound = preload("res://assets/audio/sfx/player/player_pick_up_weapon.wav")

export(float) var __attack_delay = 0.8

export var weapon_index = -1

onready var __player_owner = get_parent().get_parent()

onready var __attack_delay_timer = $AttackDelayTimer

var __can_attack = true
var __is_attacking = false

func is_attacking():
	return __is_attacking
	
func set_can_attack(value):
	__can_attack = value

func attack():
	if !__can_attack or __is_attacking: return
	
	if use_attacking_delay:
		__attack_delay_timer.start(__attack_delay)
	__is_attacking = true
	
	if __player_owner.get_looking_vector().y > 0 and !__player_owner.is_on_ground():
		emit_signal("downwards_attack")
	else:
		emit_signal("attacked")
		
func manually_end_attack_cycle():
	__is_attacking = false
	__attack_delay_timer.stop()
	emit_signal("attack_cycle_end")
	
func get_owner_player():
	return __player_owner
	
func equip():
#	__player_owner.set_sprite_frames(__player_sprite_frames)
	__player_owner.parent_world.play_sound(__pick_up_sound)
	
func drop():
	var collectible = __player_owner.parent_world.spawn_entity_deferred(__collectible_scene, __player_owner.position)
	collectible.weapon = self
	collectible.set_velocity(Vector2(-__player_owner.get_horizontal_looking_dir() * 50, -100))
	collectible.call_deferred("set_sprite", __collectible_sprite)
	__player_owner.stats.remove_child(self)
	collectible.set_recently_dropped(true)
	emit_signal("dropped")
	__attack_delay_timer.stop()
	__can_attack = true
	__is_attacking = false

func _on_AttackDelayTimer_timeout():
	__is_attacking = false
	emit_signal("attack_cycle_end")
