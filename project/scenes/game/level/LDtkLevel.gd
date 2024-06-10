extends Node2D

var __room_scene = preload("res://scenes/game/level/Room.tscn")

var __scene_escape_area = preload("res://scenes/game/world/objective/EscapeArea.tscn")
var __scene_bomb_switch = preload("res://scenes/game/world/objective/BombSwitch.tscn")

var __sound_effect_scene = preload("res://scenes/game/world/sound_pool/TemporarySoundEffect.tscn")
var __delayed_sound_scene = preload("res://scenes/game/world/sound_pool/DelayedSoundEffect.tscn")

onready var __sound_pool = $SoundPool

onready var __parallax_sprite = $ParallaxBackground/ParallaxLayer/Sprite
var __delayed_sounds = {}

var __has_check_point = false
var __check_point_room = null
var __check_point_position = null

func _ready():
	load_from_file("res://assets/ldtk/template.ldtk")

func set_check_point_enabled(value):
	__has_check_point = true
	
# TODO fix this
func set_check_point_location_and_room(room, location):
	__check_point_room = room
	__check_point_position = location
	
func has_check_point():
	return __has_check_point

func get_entity_scene_by_ldtk_identifier(identifier):
		match identifier:
			"EscapeLevelEntry": return __scene_escape_area # TODO
			"BombSwitch": return __scene_bomb_switch
		return null

func load_from_file(filepath):
	var file = File.new()
	file.open(filepath, file.READ)
	var json_data = file.get_as_text()
	var json_dict = JSON.parse(json_data).result
	var rooms = json_dict["levels"]
	for i in range(len(rooms)):
		var r = rooms[i]
		var layers = r["layerInstances"]
		var data_entity_pool
		var data_custom_tilemap
		# Find correct layers and set them to vars
		for j in range(len(layers)):
			match layers[j]["__identifier"]:
				"EntityPool": data_entity_pool = layers[j]
				"CustomTileMap": data_custom_tilemap  = layers[j]
				_: print("Unrecognized layer type:", layers[j]["__identifier"])
		
		var room_x = r["worldX"]
		var room_y = r["worldY"]
		var room_instance = __room_scene.instance()
		add_child(room_instance)
		room_instance.position = Vector2(room_x, room_y)

		var int_grid = data_custom_tilemap["intGridCsv"]
		var map_width = data_custom_tilemap["__cWid"]
		var map_height = data_custom_tilemap["__cHei"]
		for y in range(map_height):
			for x in range(map_width):
				 # Needs to be subtracted by 1 due to how Godot reads tile values
				var tile_value = int_grid[y * map_width + x]-1
				room_instance.get_tile_map().set_cellv(Vector2(x, y), tile_value)
				room_instance.get_tile_map().update_bitmask_area(Vector2(x, y))

		## Add entities to pool
		var entity_instances = data_entity_pool["entityInstances"]
		for j in range(len(entity_instances)):
			var entity_name = entity_instances[j]["__identifier"]
			var entity_scene = get_entity_scene_by_ldtk_identifier(entity_name)
			if entity_scene != null:
				var pos_x =  entity_instances[j]["px"][0]
				var pos_y =  entity_instances[j]["px"][1]
				room_instance.spawn_entity(entity_scene, Vector2(pos_x, pos_y))
				continue
			print("Unrecognized entity type: ", entity_name)
		
		

func play_sound(stream, delay=0):
	var sound
	if delay > 0:
		if !__delayed_sounds.has(stream.resource_path):
			sound = __delayed_sound_scene.instance()
			sound.delay = delay
			__delayed_sounds[stream.resource_path] = true
			sound.stream = stream
			__sound_pool.add_child(sound)
			sound.connect("can_play", self, "_on_sound_can_play")
			sound.call_deferred("play")
		return
	sound = __sound_effect_scene.instance()
	sound.stream = stream
	__sound_pool.add_child(sound)
	sound.call_deferred("play")
		
func _on_sound_can_play(sound):
	__delayed_sounds.erase(sound.stream.resource_path)
