extends Node2D

onready var __out_hit_box = $OutHitBox

onready var __sprite = $AnimatedSprite

onready var __top_line = $StaticBody2D/TopLine
onready var __left_line = $StaticBody2D/LeftLine
onready var __right_line = $StaticBody2D/RightLine
onready var __down_timer = $DownTimer
onready var __in_hit_box_shape = $InHitBox/CollisionShape2D
onready var __out_hit_box_shape = $OutHitBox/CollisionShape2D

func _on_OutHitBox_hit_dealt(hitbox):
	hitbox.take_hit(__out_hit_box, 1)

func set_enabled(value):
	__sprite.animation =  "up" if value else "down"
	
	__top_line.set_deferred("disabled", !value)
	__left_line.set_deferred("disabled", !value)
	__right_line.set_deferred("disabled", !value)
	
	__in_hit_box_shape.set_deferred("disabled", !value)
	__out_hit_box_shape.set_deferred("disabled", !value)

func _on_InHitBox_hit_received(hitbox, damage, damage_type):
	if damage_type == "energy":
		set_enabled(false)
		__down_timer.start()

func _on_DownTimer_timeout():
	set_enabled(true)
