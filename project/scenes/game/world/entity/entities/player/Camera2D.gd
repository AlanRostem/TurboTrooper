extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var __follow_node

var __height_index = 0
var __height_offset = 0
var __transition_direction = 0

var __limit_x
var __limit_y

const WIDTH = 160
const HEIGHT = 144
const SPEED = 3

func set_height_index_by_ypos(ypos):
	__height_index = int(ypos / HEIGHT)
	print("height idx:", __height_index)
	
func set_follow(node):
	__follow_node = node
	
func set_bounds(bounds: Rect2, player_pos: Vector2):
	__limit_x = bounds.size.x 
	__limit_y = bounds.size.y
#	limit_left = bounds.position.x#clamp(bounds.position.x, 0, INF);
#	limit_top = bounds.position.x#clamp(bounds.position.y, 0, INF);
#	limit_right = bounds.size.x + bounds.position.x;
#	limit_bottom = bounds.size.y + bounds.position.y;
	position = player_pos
	set_height_index_by_ypos(player_pos.y)
	
func _physics_process(delta):
	var drag_x = 0.1
	var margin_x = drag_x * WIDTH
	var drag_y = 1.0
	var margin_y = drag_y * HEIGHT

	if __follow_node.position.x > (position.x + margin_x): # Right
		position.x = (__follow_node.position.x - margin_x)
	elif __follow_node.position.x < (position.x - margin_x): # Left
		position.x = (__follow_node.position.x + margin_x)
	
	if __follow_node.position.y > (position.y + margin_y): # Bottom
		position.y = (__follow_node.position.y - margin_y)
	elif __follow_node.position.y < (position.y - margin_y): # Top
		position.y = (__follow_node.position.y + margin_y)
		
	position.x = clamp(position.x, WIDTH/2, __limit_x-WIDTH/2)
#	position.y = clamp(position.y, HEIGHT/2, __limit_y-HEIGHT/2)
	position.y = __limit_y - HEIGHT/2
		
	var desired = (__height_index+1) * HEIGHT
	if __transition_direction != 0:
		__limit_y += sign(__transition_direction) * SPEED
		if __transition_direction < 0 and __limit_y < desired:
			__limit_y = desired
		if __transition_direction > 0 and __limit_y > desired:
			__limit_y = desired
		if __limit_y == desired:
			get_tree().paused = false
			__transition_direction = 0
			print("done")
		return
	
	var live_height_index = int(__follow_node.position.y / HEIGHT)
	if __height_index != live_height_index:
		__transition_direction = live_height_index - __height_index
		print("change:", __height_index, "->", live_height_index)
		__height_index = live_height_index
		get_tree().paused = true
