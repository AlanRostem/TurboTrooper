extends "res://scenes/game/level/Level.gd"

onready var __bomb_timer = $BombTimer

func start_bomb_timer():
	__bomb_timer.start()
