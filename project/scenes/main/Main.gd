extends Node2D


func _physics_process(delta):
	# Quits the game if both select and start is pressed on some handhelds
	if Input.is_action_pressed("select") and Input.is_action_pressed("pause"):
		get_tree().quit()
