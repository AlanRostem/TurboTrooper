# This node contains all world collision and an entity pool. Spawning/despawning of
# entities is managed by this node, but are attached to the entity pool node

extends Node2D

class_name GameWorld

const SOLID_OBJECT_COLLISION_BIT = 0

var __hover_text_scene = preload("res://scenes/ui/world/hover_text/WorldHoverText.tscn")

var __sound_effect_scene = preload("res://scenes/game/world/sound_pool/TemporarySoundEffect.tscn")
var __delayed_sound_scene = preload("res://scenes/game/world/sound_pool/DelayedSoundEffect.tscn")

onready var __geometry = $Geometry
onready var __entity_pool = $EntityPool

var __hide_entities = false

onready var __tile_map = $Geometry/CustomTileMap

onready var __parent_level = get_parent()
onready var __sound_pool = $SoundPool

var player_node

onready var __parallax_sprite = $ParallaxBackground/ParallaxLayer/Sprite

onready var __scrap_hover_text = $ScrapHoverText
onready var __weapon_hover_text = $WeaponHoverText

var __scrap_recently_collected = 0
var __remove_all_entities = false

var __delayed_sounds = {}

func _ready():
	var player = __entity_pool.get_node_or_null("Player")
	if player != null:
		assign_player_node(player)
		var rect = __tile_map.get_used_rect()
		rect.position *= __tile_map.get_tile_size()
		rect.size *= __tile_map.get_tile_size()
		player.set_camera_bounds(rect)
		
func hide_and_remove_entities():
	__geometry.visible = false
	set_remove_all_entities(true)
	__parallax_sprite.visible = false
	
func set_remove_all_entities(value):
	__remove_all_entities = value

func remove_all_entities():
	return __remove_all_entities

func get_parent_level():
	return __parent_level

func assign_player_node(player):
	player_node = player
	__parent_level.player_node = player

# Retrieve the pixel cell size for the tile map
func get_tile_size():
	return __tile_map.get_tile_size()

# Instance a node that inherits the base entity scene through a specified scene and
# specify a relative location for the entity to be present. The node is then added as 
# a child of the EntityPool node.
func spawn_entity(entity_scene, location):
	var entity = entity_scene.instance()
	entity.position = location
	entity.parent_world = self
	__entity_pool.add_child(entity)
#	if entity is Player:
#		assign_player_node(entity)
	return entity
	
func add_geometry(scene, location):
	var geometry = scene.instance()
	geometry.position = location
	__geometry.add_child(geometry)
	return geometry
	
# Instance a node that inherits the base entity scene through a specified scene and
# specify a relative location for the entity to be present. The node is then added as 
# a child of the EntityPool node. The adding is deferred. 
func spawn_entity_deferred(entity_scene, location):
	var entity = entity_scene.instance()
	entity.position = location
	entity.parent_world = self
	__entity_pool.call_deferred("add_child", entity)
#	if entity is Player:
#		assign_player_node(entity)
	return entity

func get_entity_pool():
	return  __entity_pool
	
func get_geometry():
	return __geometry

func get_tile_map():
	return __tile_map

func show_effect_deferred(scene, location):
	var effect = scene.instance()
	effect.position = location
	__entity_pool.call_deferred("add_child", effect)
	
func show_hover_scrap_collected(amount, location):
	__scrap_recently_collected += amount
	__scrap_hover_text.display("+" + str(__scrap_recently_collected), location)

func show_hover_weapon_collected(weapon_name, location):
	__weapon_hover_text.display("+" + weapon_name, location)
	
# Uses weapon hover text
func show_hover_text(text, location):
	__weapon_hover_text.display(text, location)

func _on_ScrapHoverText_display_off():
	__scrap_recently_collected = 0
	
func play_sound(stream: AudioStream, delay = 0):
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


func _on_DeathPits_body_entered(player):
	player.die()
