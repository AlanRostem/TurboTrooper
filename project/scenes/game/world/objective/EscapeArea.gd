extends Area2D

signal completed()

onready var parent_world = get_parent().get_parent()

var __is_blocking = false
var __is_bomb_switch_active = false
var __bomb_switch 

func set_blocking(flag):
	__is_blocking = flag
	$Blockade/CollisionShape2D.set_deferred("disabled", !flag)
	
func set_waiting_for_player(flag):
	__is_bomb_switch_active = flag
	$ArrowSprite.visible = flag
	$Blockade/CollisionShape2D.set_deferred("disabled", flag)

func connect_to_bomb_switch(bomb_switch):
	bomb_switch.connect("activated", self, "__on_bomb_switch_activated")
	bomb_switch.connect_to_escape_area(self)
	__bomb_switch = bomb_switch
	
func connect_to_boss_area(boss_area):
	pass
	
func __on_bomb_switch_activated():
	set_waiting_for_player(true)

func _on_EscapeArea_body_entered(player):
	if __is_bomb_switch_active:
		player.state_machine.transition_to("PlayerLeaveLevelState")
		$ArrowSprite.visible = false
#		__bomb_switch.complete()
		emit_signal("completed")
		return
	
	if !__is_blocking:
		set_blocking(true)
