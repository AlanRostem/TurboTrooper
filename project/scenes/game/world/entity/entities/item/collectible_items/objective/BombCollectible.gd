extends "res://scenes/game/world/entity/entities/item/collectible_items/objective/ObjectiveItem.gd"

func _on_attached_to_player(player):
	parent_world.get_parent_level().set_player_has_bomb(true)

func plant(location):
	set_can_collect(false)
	set_attached_to_player(false)
	set_arrow_visible(false)
	position = location
	set_velocity(Vector2.ZERO)
