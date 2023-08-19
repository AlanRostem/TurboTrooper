extends Level

func _on_EscapeArea_completed():
	player_node.state_machine.transition_to("PlayerLeaveLevelState")
	
