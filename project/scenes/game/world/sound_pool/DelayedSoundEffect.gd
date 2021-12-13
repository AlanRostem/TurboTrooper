extends "res://scenes/game/world/sound_pool/TemporarySoundEffect.gd"

signal can_play(sound)

export var delay: float

onready var __timer = $Timer

func _ready():
	assert(delay < stream.get_length())
	__timer.start(delay)

func _on_Timer_timeout():
	emit_signal("can_play", self)
