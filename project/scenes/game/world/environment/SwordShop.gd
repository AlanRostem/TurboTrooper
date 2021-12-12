extends "res://scenes/game/world/environment/WeaponShop.gd"

func _purchase_condition(player):
	if !player.stats.has_weapon(): return true
	return player.stats.get_weapon().name != "Sword"

func _purchase_response(player):
	._purchase_response(player)
	player.parent_world.show_hover_weapon_collected("Sword", player.position)
