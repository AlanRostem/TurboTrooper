extends AnimatedSprite

onready var rush_rogue = get_parent()

func _process(delta):
	flip_h = rush_rogue.horizontal_looking_direction > 0
	match rush_rogue.state_machine.get_current_state():
		"RushRoguePatrolState": animation = "patrol"
		"RushRogueRushState": animation = "rush"
		"RushRogueChargeUpState": animation = "charge"
