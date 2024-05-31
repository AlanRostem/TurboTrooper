extends Node2D

var __room_scene = preload("res://scenes/game/level/Room.tscn")

var __sound_effect_scene = preload("res://scenes/game/world/sound_pool/TemporarySoundEffect.tscn")
var __delayed_sound_scene = preload("res://scenes/game/world/sound_pool/DelayedSoundEffect.tscn")
onready var __sound_pool = $SoundPool

onready var __parallax_sprite = $ParallaxBackground/ParallaxLayer/Sprite
var __delayed_sounds = {}

func _ready():
	load_from_file("res://assets/ldtk/template.ldtk")
	
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
				
		
func _on_sound_can_play(sound):
	__delayed_sounds.erase(sound.stream.resource_path)
