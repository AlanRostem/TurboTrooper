extends Node2D

onready var __out_hit_box = $OutHitBox

func _on_OutHitBox_hit_dealt(hitbox):
	hitbox.take_hit(__out_hit_box, 1)
