extends Area2D

signal completed()

onready var parent_world = get_parent().get_parent()

func _on_RushEscapeArea_body_entered(player):
	emit_signal("completed")
	$ArrowSprite.visible = false
	player.state_machine.transition_to("PlayerLeaveLevelState", {"right": true})
