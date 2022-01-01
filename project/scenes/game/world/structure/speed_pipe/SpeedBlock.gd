extends StaticBody2D


onready var __sprite = $AnimatedSprite
onready var __shape = $CollisionShape2D
onready var __timer = $Timer

var __alternate_visibility = false

func _ready():
	get_parent().connect("player_entered", self, "_on_player_entered")

func _process(delta):
	if __timer.time_left <= 0.2 * __timer.wait_time and __alternate_visibility:
		visible = !visible
	elif !visible:
		visible = true

func _on_player_entered():
	set_activated(true)


func set_activated(value):
	__alternate_visibility = value
	__shape.set_deferred("disabled", !value)
	if value:
		__sprite.animation = "on"
		__timer.start()
	else:
		__sprite.animation = "off"


func _on_Timer_timeout():
	set_activated(false)
