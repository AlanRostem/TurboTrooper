extends "res://scenes/game/world/environment/Shop.gd"


func _purchase_condition(player):
	return not "Blaster" in player.stats.get_weapon().name

func _purchase_response(player):
	player.stats.get_weapon().add_ammo(30) # TODO: Dummy value
	player.parent_world.show_hover_weapon_collected("+30 ammo", player.position)
