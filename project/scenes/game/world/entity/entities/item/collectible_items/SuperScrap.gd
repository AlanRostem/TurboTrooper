extends "res://scenes/game/world/entity/entities/item/CollectibleItem.gd"

const MAX_SCRAP_REWARD = 500

func _player_collected(player):
	var scrap_reward = MAX_SCRAP_REWARD
	if player.stats.get_health() == PlayerStats.MAX_HEALTH:
		scrap_reward *= 2
	else:
		player.stats.set_health(PlayerStats.MAX_HEALTH)
		parent_world.show_hover_text("+max life", player.position + Vector2.UP * 8)
		
	player.stats.add_scrap(scrap_reward)
	parent_world.show_hover_scrap_collected(scrap_reward, player.position)
