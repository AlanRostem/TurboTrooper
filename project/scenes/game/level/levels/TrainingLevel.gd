extends "res://scenes/game/level/level_types/BombLevel.gd"


onready var __tutorial_texts = $GameWorld/TutorialTexts

func _ready():
	if game_handler.has_check_point():
		__tutorial_texts.visible = false

func _on_BombSwitch_activated_for_training():
	__tutorial_texts.visible = false
