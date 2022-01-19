extends "res://scenes/game/world/environment/Shop.gd"

onready var __buy_sound = $BuySound
		
		
func _purchase_condition(player):
	return player.stats.get_health() < player.stats.MAX_HEALTH * 2
		
func _purchase_response(player):
	player.stats.add_one_health()
	player.parent_world.show_hover_text("+1 life", player.position)
	__buy_sound.play()
