extends "res://scenes/game/world/weapon/Weapon.gd"

const CRITICAL_DAMAGE = 8
const STANDARD_DAMAGE = 1

var __projectile_scene = preload("res://scenes/game/world/entity/entities/projectile/projectiles/ShieldBlastProjectile.tscn")

func _on_BlastCannonWeapon_attacked():
	fire_projectile(__projectile_scene)

func fire_projectile(scene):
	use_ammo()

	var player = get_owner_player()
	var world = player.parent_world
	var projectile = world.spawn_entity_deferred(scene, player.position)
	
	var dir = player.get_looking_vector()
	var offset = Vector2(position)
	if dir.y == 1:
		projectile.damage = CRITICAL_DAMAGE
		projectile.damage_type = HealthComponent.DAMAGE_TYPE_CRITICAL
	else:
		offset.y -= 3
	projectile.call_deferred("init_from_player_weapon", dir, self, offset)
	if !has_ammo():
		get_owner_player().stats.destroy_weapon_and_set_to_beam_cannon()
		get_owner_player().is_gravity_enabled = true

func _on_BlastCannonWeapon_downwards_attack():
	fire_projectile(__projectile_scene)
	var player = get_owner_player()
	if player.stats.get_rush_energy() > 0:
		player.recoil_boost(150)
		player.stats.use_rush_energy(1)
