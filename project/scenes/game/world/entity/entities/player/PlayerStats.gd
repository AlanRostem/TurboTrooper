extends Node2D
class_name PlayerStats

const MAX_HEALTH = 3
const MAX_RUSH_ENERGY = 6
const MAX_SCORE = 99999

const SWORD_WEAPON_IDX = 0
const BLASTER_WEAPON_IDX = 1

signal scrap_changed(value)
signal health_changed(value)
signal score_changed(value)
signal died()
signal rush_energy_changed(value)
signal rush_energy_consumed()
signal weapon_changed(weapon)
signal weapon_ammo_changed(value)

export(PackedScene) var test_weapon_scene

var __default_player_sprite_frames = preload("res://assets/resources/sprite_frames/char/PlayerSpriteFrames.tres")

var __scrap_count = 0
var __dirty_scrap = 0
var __rush_energy_count = MAX_RUSH_ENERGY
var __health = MAX_HEALTH

var __equipped_weapon
var __weapon_idx = -1

var __is_recharging_rush_energy = false
var __score = 0

var __sword_scene = preload("res://scenes/game/world/weapon/Sword.tscn")
var __blaster_scene = preload("res://scenes/game/world/weapon/Blaster.tscn")

onready var __player = get_parent()
onready var __rush_energy_recharge_timer = $RushEnergyRechargeTimer
onready var __rush_energy_recharge_starting_delay_timer = $RushEnergyRechargeStartingDelayTimer

func _ready():
	if test_weapon_scene != null:
		call_deferred("equip_test_weapon")
	call_deferred("set_rush_energy", MAX_RUSH_ENERGY)
	call_deferred("set_health", MAX_HEALTH)
	call_deferred("emit_signal", "scrap_changed", __scrap_count)
	

func _physics_process(delta):
	if __player.is_on_ground():
		if __player.is_aiming_down():
			__player.stop_aiming_down()
		if __rush_energy_count < MAX_RUSH_ENERGY and !__is_recharging_rush_energy:
			__rush_energy_recharge_starting_delay_timer.start()
			__is_recharging_rush_energy = true
	
	if __equipped_weapon == null: return
	if Input.is_action_just_pressed("fire"):
		__equipped_weapon.attack()
		
	if Input.is_action_just_pressed("aim_down"):
		if __player.state_machine.get_current_state() == "PlayerAirBorneState":
			__player.toggle_aim_down()
			
	if Input.is_action_just_pressed("aim_up"):
		__player.set_aim_up(true)
	elif Input.is_action_just_released("aim_up"):
		__player.set_aim_up(false)
	
func set_from_data(data: Dictionary):
	set_score(data["score"])
	match data["weapon"]:
		SWORD_WEAPON_IDX: instance_and_equip_weapon(__sword_scene)
		BLASTER_WEAPON_IDX: instance_and_equip_weapon(__blaster_scene)
	
func get_data():
	return {
		"score": get_score(),
		"weapon": __weapon_idx
	}
	
func add_score(score):
	set_score(__score + score)
	
func set_score(score):
	__score = clamp(score, 0, MAX_SCORE)
	emit_signal("score_changed", __score)
	
func get_score():
	return __score
	
func has_weapon():
	return __equipped_weapon != null
	
func get_weapon():
	return __equipped_weapon
	
func dirty_set_scrap(scrap):
	__dirty_scrap = scrap
	
func instance_and_equip_weapon(scene):
	var weapon = scene.instance()
	equip_weapon(weapon)

func equip_weapon(weapon):
	if has_weapon():
		__equipped_weapon.drop()
	__equipped_weapon = weapon
	__weapon_idx = weapon.weapon_index
	add_child(__equipped_weapon)
	__equipped_weapon.equip()
	emit_signal("weapon_changed", __equipped_weapon)

func equip_test_weapon():
	instance_and_equip_weapon(test_weapon_scene)
	
func get_equipped_weapon():
	return __equipped_weapon

func set_scrap(count):
	__scrap_count = count
	emit_signal("scrap_changed", __scrap_count)

func add_scrap(count):
	set_scrap(__scrap_count + count)
	
func lose_scrap(count):
	__scrap_count = clamp(__scrap_count - count, 0, INF)
	emit_signal("scrap_changed", __scrap_count)
	
func get_scrap_count():
	return __scrap_count

func take_one_damage():
	if __health == 0: return
	set_health(__health - 1)
	if __equipped_weapon != null:
		__equipped_weapon.drop()
		__player.set_sprite_frames(__default_player_sprite_frames)
		__equipped_weapon = null
		__player.set_aim_up(false)
		__player.stop_aiming_down()
	if !__player.is_roof_above():
		__player.set_velocity_x(0)
	if __health == 0:
		emit_signal("died")
		__player.become_invincible()
	else:
		__player.start_invinvibility_sequence()
	
func add_one_health():
	set_health(__health + 1)
	
func set_health(value):
	__health = value
	emit_signal("health_changed", __health)

func get_health(): return __health

func get_rush_energy():
	return __rush_energy_count
	
func set_rush_energy(count):
	__rush_energy_count = clamp(count, 0, MAX_RUSH_ENERGY)
	emit_signal("rush_energy_changed", __rush_energy_count)

func use_rush_energy(count):
	set_rush_energy(__rush_energy_count - count)
	__rush_energy_recharge_starting_delay_timer.stop()
	__rush_energy_recharge_timer.stop()
	__is_recharging_rush_energy = false
	emit_signal("rush_energy_consumed")

func recharge_rush_energy():
	set_rush_energy(__rush_energy_count + 2)
	if __rush_energy_count == MAX_RUSH_ENERGY:
		__rush_energy_recharge_timer.stop()
		__is_recharging_rush_energy = false

func convert_scrap_to_score(count = 1):
	lose_scrap(count)
	add_score(count)

func _on_RushEnergyRechargeTimer_timeout():
	recharge_rush_energy()

func _on_RushEnergyRechargeStartingDelayTimer_timeout():
	__rush_energy_recharge_timer.start()
	recharge_rush_energy()

func _on_InHitBox_hit_received(hitbox, damage, damage_type):
	take_one_damage()
