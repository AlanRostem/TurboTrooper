extends Node2D

var __room_scene = preload("res://scenes/game/level/Room.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	load_from_file("res://assets/ldtk/template.ldtk")

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
		for j in range(len(layers)):
			match layers[j]["__identifier"]:
				"EntityPool": data_entity_pool = layers[j]
				"CustomTileMap": data_custom_tilemap  = layers[j]
				_: print("Unrecognized layer type:", layers[j]["__identifier"])
				
		
