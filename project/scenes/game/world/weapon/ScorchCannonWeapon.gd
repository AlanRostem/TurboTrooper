extends "res://scenes/game/world/weapon/Weapon.gd"

var __is_firing = false
var __hover_time = 0
var __do_hover = false

var HOVER_TICK_TIME = 0.2
var DAMAGE = 10

func _physics_process(delta):
	var player = get_owner_player()
	
	if player.is_aiming_down():
		$ScorchFlame.rotation_degrees = 90
		$ScorchFlame.scale.x = 1
	elif player.is_aiming_up():
		$ScorchFlame.scale.x = 1
		$ScorchFlame.rotation_degrees = -90
	else:
		$ScorchFlame.rotation_degrees = 0
		$ScorchFlame.scale.x = get_owner_player().get_horizontal_looking_dir()
	
	if !__is_firing and Input.is_action_just_pressed("fire"):
		__is_firing = true
		$ScorchFlame/AnimatedSprite.visible = true
		$DamageTickTimer.start()
		use_ammo()
		if !has_ammo():
			get_owner_player().stats.destroy_weapon_and_set_to_beam_cannon()
			get_owner_player().is_gravity_enabled = true
		if player.is_aiming_down() and player.stats.get_rush_energy() > 0:
			player.stats.use_rush_energy(1)
			__hover_time = HOVER_TICK_TIME
			__do_hover = true
			player.is_gravity_enabled = false
			player.set_velocity_y(0)
		
	elif __is_firing and Input.is_action_just_released("fire"):
		__is_firing = false
		$ScorchFlame/AnimatedSprite.visible = false
		$DamageTickTimer.stop()
		$ScorchFlame/HitBox/CollisionShape2D.set_deferred("disabled", true)
		player.is_gravity_enabled = true
		
	if __is_firing and __do_hover:
		if player.is_aiming_down() and player.stats.get_rush_energy() > 0:
			__hover_time -= delta
			if __hover_time <= 0:
				__hover_time = HOVER_TICK_TIME
				player.stats.use_rush_energy(1)
		else:
			player.is_gravity_enabled = true
			__do_hover = false
			
func _on_DamageTickTimer_timeout():
	$ScorchFlame/HitBox/CollisionShape2D.disabled = !$ScorchFlame/HitBox/CollisionShape2D.disabled
	use_ammo()
	if !has_ammo():
		get_owner_player().stats.destroy_weapon_and_set_to_beam_cannon()
		get_owner_player().is_gravity_enabled = true

func _on_HitBox_hit_dealt(hitbox):
	hitbox.take_hit($ScorchFlame/HitBox, DAMAGE)
