extends Node2D
class_name PlayerStats

const MAX_HEALTH = 3
const MAX_RUSH_ENERGY = 3
const MAX_SCORE = 99999

const NO_WEAPON_IDX = -1
const BLASTER_WEAPON_IDX = 0
const SCORCH_CANNON_IDX = 1
const BLAST_CANNON_IDX = 2
const MAX_WEAPONS = 3

signal scrap_changed(value)
signal health_changed(value)
signal score_changed(value)
signal died()
signal rush_energy_changed(value)
signal rush_energy_consumed()
signal weapon_changed(weapon)
signal weapon_ammo_changed(wname, value)
signal turbo_slide_status_changed(flag)

export(PackedScene) var test_weapon_scene

var __default_player_sprite_frames = preload("res://assets/resources/sprite_frames/char/PlayerSpriteFrames.tres")

var __data = {
	"scrap": 0,
	"life": MAX_HEALTH,
	"weapon": -1,
	"score": 0,
	"checkpoint": null,
	"weapons_and_ammo": {
		BLASTER_WEAPON_IDX: 0,
		SCORCH_CANNON_IDX: 0,
		BLAST_CANNON_IDX: 0,
	}
}

var __rush_energy_count = MAX_RUSH_ENERGY

var __equipped_weapon

var __is_recharging_rush_energy = false

var __can_turbo_slide = false

var __sword_scene = preload("res://scenes/game/world/weapon/Sword.tscn")
var __blaster_scene = preload("res://scenes/game/world/weapon/Blaster.tscn")
var __scorch_cannon_scene = preload("res://scenes/game/world/weapon/ScorchCannonWeapon.tscn")
var __blast_cannon_scene = preload("res://scenes/game/world/weapon/BlastCannonWeapon.tscn")

onready var __player = get_parent()
onready var __rush_energy_recharge_timer = $RushEnergyRechargeTimer
onready var __rush_energy_recharge_starting_delay_timer = $RushEnergyRechargeStartingDelayTimer
onready var __damage_sound = $DamageSound

export var __infinite_health = false

func _ready():
	if test_weapon_scene != null:
		call_deferred("equip_test_weapon")
	call_deferred("set_rush_energy", MAX_RUSH_ENERGY)
#	call_deferred("emit_signal", "scrap_changed", __scrap_count)
	

func _physics_process(delta):
	if __player.is_on_ground():
		if __player.is_aiming_down():
			__player.stop_aiming_down()
		if __rush_energy_count < MAX_RUSH_ENERGY and !__is_recharging_rush_energy:
			__rush_energy_recharge_starting_delay_timer.start()
			__is_recharging_rush_energy = true
	
	var p = __player
	var dpad_on = p.is_on_ground() and \
		p.is_moving_exactly_at_speed(PlayerSpeedValues.PLAYER_TOP_SPRINT_SPEED) and \
		p.stats.get_rush_energy() >= 2 and \
		p.state_machine.get_current_state() == "PlayerRunState"
		
	if dpad_on != __can_turbo_slide:
		__can_turbo_slide = dpad_on
		emit_signal("turbo_slide_status_changed", __can_turbo_slide)
	
	if __equipped_weapon == null: return
	if Input.is_action_just_pressed("fire"):
		__equipped_weapon.attack()
		
	if Input.is_action_just_pressed("aim_down"):
		if !__player.is_on_ground(): # TODO: Verify correctness after this got changed
			__player.toggle_aim_down()
			
	if Input.is_action_just_pressed("aim_up"):
		__player.set_aim_up(true)
	elif Input.is_action_just_released("aim_up"):
		__player.set_aim_up(false)
		
	if Input.is_action_just_pressed("select"):
		cycle_weapon()
	
		
func set_check_point(checkpoint):
	__data["checkpoint"] = checkpoint
	
func get_check_point():
	return __data["checkpoint"]
	
func set_from_data(data: Dictionary):
	print(data)
	set_health(data["life"])
	set_scrap(data["scrap"])
	set_score(data["score"])
	set_check_point(data["checkpoint"])
	match data["weapon"]:
		NO_WEAPON_IDX: 
			instance_and_equip_weapon(__blaster_scene)
			data["weapon"] = BLASTER_WEAPON_IDX
		BLASTER_WEAPON_IDX: instance_and_equip_weapon(__blaster_scene)
		SCORCH_CANNON_IDX: instance_and_equip_weapon(__scorch_cannon_scene)
		BLAST_CANNON_IDX: instance_and_equip_weapon(__blast_cannon_scene)
	print("weapon:", data["weapon"])
	__data["weapons_and_ammo"]=data["weapons_and_ammo"]
	__equipped_weapon.add_ammo(data["weapons_and_ammo"][data["weapon"]])

func __instance_weapon_instance_by_idx(idx):
	match idx:
		NO_WEAPON_IDX: instance_and_equip_weapon(__blaster_scene)
		BLASTER_WEAPON_IDX: instance_and_equip_weapon(__blaster_scene)
		SCORCH_CANNON_IDX: instance_and_equip_weapon(__scorch_cannon_scene)
		BLAST_CANNON_IDX: instance_and_equip_weapon(__blast_cannon_scene)

func destroy_weapon_and_set_to_beam_cannon():
	__equipped_weapon.queue_free()
	__equipped_weapon = null
	instance_and_equip_weapon(__blaster_scene)

func get_data():
	return __data
	
func add_score(score):
	set_score(__data["score"] + score)
	
func set_score(score):
	__data["score"] = clamp(score, 0, MAX_SCORE)
	emit_signal("score_changed", __data["score"])
	
func get_score():
	return __data["score"]
	
func has_weapon():
	return __equipped_weapon != null
	
func get_weapon():
	return __equipped_weapon
	
func instance_and_equip_weapon(scene):
	var weapon = scene.instance()
	equip_weapon(weapon)

func equip_weapon(weapon):
	if has_weapon():
		__equipped_weapon.drop()
	__equipped_weapon = weapon
	__data["weapon"] = weapon.weapon_index
	add_child(__equipped_weapon)
	__equipped_weapon.equip()
	__equipped_weapon.add_ammo(__data["weapons_and_ammo"][__data["weapon"]])
	emit_signal("weapon_changed", __equipped_weapon)
	__equipped_weapon.connect("ammo_changed", self, "__on_weapon_ammo_changed")

func equip_test_weapon():
	instance_and_equip_weapon(test_weapon_scene)
	
func get_equipped_weapon():
	return __equipped_weapon

func cycle_weapon():
	var idx = __data["weapon"]
	while true:
		idx = (idx+1) % MAX_WEAPONS
		var ammo = __data["weapons_and_ammo"][idx]
		if idx == BLASTER_WEAPON_IDX or ammo != 0:
			break
	__instance_weapon_instance_by_idx(idx)

func get_ammo_for(wname):
	var idx = 0
	match wname:
		"ScorchCannonWeapon": idx = SCORCH_CANNON_IDX
		"BlastCannonWeapon": idx = BLAST_CANNON_IDX
	assert(idx != 0)
	return __data["weapons_and_ammo"][idx]

func set_scrap(count):
	__data["scrap"] = count
	emit_signal("scrap_changed", __data["scrap"])

func add_scrap(count):
	set_scrap(__data["scrap"] + count)
	
func lose_scrap(count):
	__data["scrap"] = clamp(__data["scrap"] - count, 0, INF)
	emit_signal("scrap_changed", __data["scrap"])
	
func get_scrap_count():
	return __data["scrap"]

func take_one_damage():
	if __data["life"] == 0 or __player.is_invincible(): return
	if !__infinite_health:
		set_health(__data["life"] - 1)
#	if __equipped_weapon != null:
#		__equipped_weapon.drop()
#		__player.set_sprite_frames(__default_player_sprite_frames)
#		__equipped_weapon = null
#		__player.set_aim_up(false)
#		__player.stop_aiming_down()
#	if !__player.is_roof_above():
#		__player.set_velocity_x(0)
	if __data["life"] == 0:
		emit_signal("died")
		__player.become_invincible()
	else:
		__player.start_invinvibility_sequence()
		__damage_sound.play()
		__data["weapon"] = -1

	
func add_one_health():
	set_health(__data["life"] + 1)
	
func set_health(value):
	__data["life"] = value
	emit_signal("health_changed", __data["life"])

func get_health(): return __data["life"]

func get_rush_energy():
	return __rush_energy_count
	
func set_rush_energy(count):
	__rush_energy_count = clamp(count, 0, MAX_RUSH_ENERGY)
	emit_signal("rush_energy_changed", __rush_energy_count)
	
func refill_rush_energy():
	set_rush_energy(MAX_RUSH_ENERGY)

func use_rush_energy(count):
	set_rush_energy(__rush_energy_count - count)
#	__rush_energy_recharge_starting_delay_timer.stop()
#	__rush_energy_recharge_timer.stop()
#	__is_recharging_rush_energy = false
	emit_signal("rush_energy_consumed")

func recharge_rush_energy():
	set_rush_energy(__rush_energy_count + 2)
	if __rush_energy_count == MAX_RUSH_ENERGY:
		__rush_energy_recharge_timer.stop()
		__is_recharging_rush_energy = false

func convert_scrap_to_score(count = 1):
	var c = count
	lose_scrap(c)
	add_score(c)

func _on_RushEnergyRechargeTimer_timeout():
	recharge_rush_energy()

func _on_RushEnergyRechargeStartingDelayTimer_timeout():
	__rush_energy_recharge_timer.start()
	recharge_rush_energy()

func _on_InHitBox_hit_received(hitbox, damage, damage_type):
	take_one_damage()

func __on_weapon_ammo_changed(wname, ammo):
	emit_signal("weapon_ammo_changed", wname, ammo)
	__data["weapons_and_ammo"][__data["weapon"]] = ammo
