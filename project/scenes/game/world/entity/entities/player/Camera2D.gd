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
const SPEED_UP = 1
const SPEED_DOWN = 3

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
	var drag_max_y = 0.0
	var drag_min_y = 0.2

	if __follow_node.position.x > (position.x + margin_x): # Right
		position.x = (__follow_node.position.x - margin_x)
	elif __follow_node.position.x < (position.x - margin_x): # Left
		position.x = (__follow_node.position.x + margin_x)
	
	if __follow_node.position.y > (position.y + drag_max_y * HEIGHT): # Bottom
		position.y = (__follow_node.position.y - drag_max_y * HEIGHT)
	elif __follow_node.position.y < (position.y - drag_min_y * HEIGHT): # Top
		position.y = (__follow_node.position.y + drag_min_y * HEIGHT)
		
	position.x = clamp(position.x, WIDTH/2, __limit_x-WIDTH/2)
#	position.y = clamp(position.y, HEIGHT/2, __limit_y-HEIGHT/2)
	position.y = clamp(position.y, HEIGHT/2, __limit_y-HEIGHT/2)
		
	var live_height_index = int(__follow_node.position.y / HEIGHT)
	var camera_height_index = int(position.y / HEIGHT)
	var desired = (live_height_index+1) * HEIGHT
	var speed = SPEED_UP if __transition_direction < 0 else SPEED_DOWN

	var dir = 0
	if live_height_index != __height_index:
		dir = live_height_index - __height_index
	elif camera_height_index != live_height_index:
		dir = live_height_index - camera_height_index
	var done = __update_height_transition(dir, desired)
	if done:
		__height_index = live_height_index

func __update_height_transition(dir, desired):
	var speed = SPEED_UP if dir < 0 else SPEED_DOWN
	__limit_y += sign(dir) * speed
	if dir < 0 and __limit_y < desired:
		__limit_y = desired
		return true
	if dir > 0 and __limit_y > desired:
		__limit_y = desired
		return true
	return false
