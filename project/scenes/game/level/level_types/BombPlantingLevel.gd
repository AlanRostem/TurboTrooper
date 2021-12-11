extends "res://scenes/game/level/Level.gd"

onready var __bomb_timer = $BombTimer

var __player_has_bomb = false
var __player_planted_bomb = false

var __player_entered_plant_area = false
var __player_entered_escape_area = false

onready var __bomb = $GameWorld/EntityPool/BombCollectible

onready var __plant_point = $GameWorld/Geometry/PlantPoint

func _ready():
	game_handler.get_hud().set_global_message("PLANT THE BOMB")

func _physics_process(delta):
	if __player_entered_plant_area and __player_has_bomb:
		if Input.is_action_just_pressed("fire"):
			start_bomb_timer()
			set_player_has_bomb(false)
			__player_planted_bomb = true
			__bomb.plant(__plant_point.position)
			
	if __player_planted_bomb:
		var time = str(int(__bomb_timer.time_left))
		game_handler.get_hud().set_global_message("ESCAPE! DETONATION IN " + time)

func set_player_has_bomb(value):
	__player_has_bomb = value
	if value:
		game_handler.get_hud().hide_global_message()

func player_has_bomb():
	return __player_has_bomb

func start_bomb_timer():
	__bomb_timer.start()

func _on_PlantPoint_body_entered(body):
	__player_entered_plant_area = true

func _on_PlantPoint_body_exited(body):
	__player_entered_plant_area = false
