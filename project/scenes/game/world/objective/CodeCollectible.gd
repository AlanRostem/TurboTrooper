extends "res://scenes/game/world/entity/entities/item/CollectibleItem.gd"

func _ready():
	parent_world.add_code_collectible_objective()

func _player_collected(player):
	parent_world.increment_collected_codes()
	var count = parent_world.get_max_codes() - parent_world.get_codes()
	if count == 0:
		parent_world.show_hover_text(
			"done!",
			position)
		return
	parent_world.show_hover_text(
		str(count) +" left",
		position)
