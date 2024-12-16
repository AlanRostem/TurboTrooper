extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var __player = get_parent()

var __height_index = 0
var __transition_direction = 0

func set_height_index_by_ypos(ypos):
	__height_index = ypos / 144
	__height_index = floor(__height_index)

func _physics_process(delta):
	if __transition_direction != 0:
		position.y += __transition_direction
		if int(__player.position.y + position.y) % 144 == 0:
			__transition_direction = 0
			print("stop: ", position.y)
		return
	
	var live_height_index = floor(__player.position.y / 144)
	if live_height_index != __height_index:
		__transition_direction = sign(live_height_index-__height_index)
		print("new: ", __height_index, "->", live_height_index)
		__height_index = live_height_index
