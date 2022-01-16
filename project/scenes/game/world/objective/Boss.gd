extends "res://scenes/game/world/objective/Objective.gd"

func _on_HealthComponent_health_depleted(health_left):
	complete()
