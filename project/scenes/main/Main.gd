extends Node2D


func _physics_process(delta):
	if Input.is_action_pressed("select") and Input.is_action_pressed("pause"):
		get_tree().quit()
