extends Label

signal display_off()

const HOVER_SPEED = 20

onready var __life_timer = $LifeTimer

func _ready():
	# This is a dirty fix
	owner = get_parent().get_parent()

func display(str_txt, location):
	rect_size.x = 0
	text = str_txt
	rect_position = location - rect_size / 2
	visible = true
	__life_timer.start()

func _physics_process(delta):
	rect_position.y += -HOVER_SPEED * delta

func _on_LifeTimer_timeout():
	visible = false
	emit_signal("display_off")
