extends "res://scenes/game/world/environment/GeometryNode.gd"

func _on_PlayerDetectionArea_body_entered(player):
	player.visible = false
	if player.state_machine.get_current_state() == "PlayerSlideState":
		activate_all_speed_blocks()

func activate_all_speed_blocks():
	for block in get_tree().get_nodes_in_group("speed_block"):
		block.set_activated(true)

func _on_PlayerDetectionArea_body_exited(player):
	player.visible = true
