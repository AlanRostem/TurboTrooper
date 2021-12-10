extends "res://scenes/game/world/objective/Objective.gd"


func is_completed():
	return _completion_cond_data["planted"] and _completion_cond_data["escaped"]
