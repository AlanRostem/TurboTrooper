extends "res://scenes/game/world/weapon/Weapon.gd"

var __is_firing = false
var __do_hover = false

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
	elif __is_firing and Input.is_action_just_released("fire"):
		__is_firing = false
		$ScorchFlame/AnimatedSprite.visible = false
		$DamageTickTimer.stop()
		$ScorchFlame/HitBox/CollisionShape2D.set_deferred("disabled", true)
		__do_hover = false
	if player.stats.get_rush_energy() == 0:
		__do_hover = false
	if __do_hover:
		player.set_velocity_y(0)
	
func _on_DamageTickTimer_timeout():
	$ScorchFlame/HitBox/CollisionShape2D.disabled = !$ScorchFlame/HitBox/CollisionShape2D.disabled
	var player = get_owner_player()
	if !player.is_aiming_down(): 
		__do_hover = false
		return
	if player.stats.get_rush_energy() > 0:
		player.stats.use_rush_energy(1)
		__do_hover = true


func _on_HitBox_hit_dealt(hitbox):
	hitbox.take_hit($ScorchFlame/HitBox, 2)
