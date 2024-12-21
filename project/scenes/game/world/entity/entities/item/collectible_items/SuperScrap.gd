extends "res://scenes/game/world/entity/entities/item/CollectibleItem.gd"

const MAX_SCRAP_REWARD = 100

var __pick_up_sound = preload("res://assets/audio/sfx/world/scrap/pick_up_big_scrap.wav")

func _player_collected(player):
	var scrap_reward = MAX_SCRAP_REWARD

	player.stats.add_one_health()
	parent_world.show_hover_text("+1 life", player.position + Vector2.UP * 8)
		
	player.stats.add_scrap(scrap_reward)
	parent_world.show_hover_scrap_collected(scrap_reward, player.position)
	parent_world.play_sound(__pick_up_sound)
