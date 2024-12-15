extends Node2D
class_name LDtkLevel

var __parallax_cave = preload("res://assets/sprites/parallax/cave.png")
var __parallax_lab = preload("res://assets/sprites/parallax/pipes.png")
var __parallax_factory = preload("res://assets/sprites/parallax/factory.png")
var __parallax_core = preload("res://assets/sprites/parallax/simulation.png")

var __tileset_res_cave = preload("res://assets/resources/CaveBiomeTileset.tres")
var __tileset_res_lab = preload("res://assets/resources/LabBiomeTileset.tres")

var __room_scene = preload("res://scenes/game/level/Room.tscn")

var __scene_player = preload("res://scenes/game/world/entity/entities/player/Player.tscn")
var __scene_escape_area = preload("res://scenes/game/world/objective/EscapeArea.tscn")
var __scene_bomb_switch = preload("res://scenes/game/world/objective/BombSwitch.tscn")
var __scene_scrap = preload("res://scenes/game/world/entity/entities/item/collectible_items/FloatingScrap.tscn")
var __scene_crate_with_scrap = preload("res://scenes/game/world/structure/destructible/CrateWithScrap.tscn")
var __scene_crate_with_scorch_cannon = preload("res://scenes/game/world/structure/destructible/ScorchCannonCrate.tscn")
var __scene_spawner_excavatron = preload("res://scenes/game/world/spawner/ExcavatronSpawner.tscn")
var __scene_spike_trap = preload("res://scenes/game/world/environment/hazards/SpikeHazard.tscn")

var __sound_effect_scene = preload("res://scenes/game/world/sound_pool/TemporarySoundEffect.tscn")
var __delayed_sound_scene = preload("res://scenes/game/world/sound_pool/DelayedSoundEffect.tscn")

onready var __sound_pool = $SoundPool

onready var __parallax_sprite = $ParallaxBackground/ParallaxLayer/Sprite
var __delayed_sounds = {}

var __has_check_point = false
var __check_point_position = null

var __escape_area_ref = null
var __bomb_switch_ref = null
var __boss_area_ref = null

var player_node

onready var game_handler = get_parent()

const SOLID_OBJECT_COLLISION_BIT = 0

var __hover_text_scene = preload("res://scenes/ui/world/hover_text/WorldHoverText.tscn")

onready var __entity_pool = $EntityPool

var __hide_entities = false

var __music_theme
var __theme_enum

onready var __tile_map = $TileMap

onready var __scrap_hover_text = $ScrapHoverText
onready var __weapon_hover_text = $WeaponHoverText

var __scrap_recently_collected = 0
var __remove_all_entities = false

func _ready():
	pass
	
func feed_init_data(has_check_point):
	__has_check_point = has_check_point
	
func init_level_states():
	if __bomb_switch_ref != null:
		__escape_area_ref.connect_to_bomb_switch(__bomb_switch_ref)
		player_node.connect_to_bomb_switch(__bomb_switch_ref)
		__check_point_position = __bomb_switch_ref.position + Vector2(8 * -3, 0)
	elif __boss_area_ref != null:
		pass
	
func init_player(player, should_transition=false):
	assign_player_node(player)
	var rect = __tile_map.get_used_rect()
	rect.position *= __tile_map.get_tile_size()
	rect.size *= __tile_map.get_tile_size()
	player.set_camera_bounds(rect)
	if !should_transition:
		player.state_machine.transition_to("PlayerIdleState")
		return
	player.state_machine.transition_to("PlayerEnterLevelState")
	
func init_event_recievers(hud):
	hud.connect_to_player(player_node)

func put_player_on_check_point(vec):
	player_node.position = vec

func set_player_stats(stats: Dictionary):
	player_node.stats.set_from_data(stats)
	if game_handler.has_check_point():
		put_player_on_check_point(player_node.stats.get_check_point())

func play_battle_theme():
	game_handler.start_battle_sequence()
	
func stop_battle_theme():
	game_handler.cancel_battle_sequence()

func set_check_point_enabled(value):
	__has_check_point = true
	
func set_check_point_position(pos):
	__check_point_position = pos

func save_check_point():
	game_handler.set_check_point(__check_point_position)
	player_node.stats.set_check_point(__check_point_position)
	
func has_check_point():
	return __has_check_point

func get_entity_scene_by_ldtk_identifier(identifier):
		match identifier:
			"EscapeLevelEntry": return __scene_escape_area
			"BombSwitch": return __scene_bomb_switch
			"Scrap": return __scene_scrap
			"CrateWithScrap": return __scene_crate_with_scrap
			"CrateWithScrochCannon": return __scene_crate_with_scorch_cannon
			"ExcavatronSpawner": return __scene_spawner_excavatron
			"SpikeTrap": return __scene_spike_trap
		return null

func set_biome_by_string(biome_str):
	match biome_str:
		"Cave": 
			__theme_enum = Level.MusicThemes.CAVE
			__tile_map.tile_set = __tileset_res_cave
			$ParallaxBackground/ParallaxLayer/Sprite.texture = __parallax_cave
		"Lab": 
			__theme_enum = Level.MusicThemes.LAB
			__tile_map.tile_set = __tileset_res_lab
			$ParallaxBackground/ParallaxLayer/Sprite.texture = __parallax_lab
		"Factory": 
			__theme_enum = Level.MusicThemes.FACTORY
			printerr("missing factory tileset")
		_: printerr("biome not found: ", biome_str)
	print("Set biome: ", biome_str)

func load_from_file(filepath):
	var file = File.new()
	file.open(filepath, file.READ)
	var json_data = file.get_as_text()
	var json_dict = JSON.parse(json_data).result
	
	var rooms = json_dict["levels"]
	# Using first room since rooms are not a thing anymore
	var r = rooms[0] # TODO: Consider this as each individual level
	var fields = r["fieldInstances"]
	
	var bomb_detonation_time = 1000 # Setting a high value to detect error
	for f in fields:
		var id = f["__identifier"]
		match id:
			"Biome": set_biome_by_string(f["__value"])
			"BombTime": bomb_detonation_time = int(f["__value"])
	
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

	var int_grid = data_custom_tilemap["intGridCsv"]
	var map_width = data_custom_tilemap["__cWid"]
	var map_height = data_custom_tilemap["__cHei"]
	for y in range(map_height):
		for x in range(map_width):
			 # Needs to be subtracted by 1 due to how Godot reads tile values
			var tile_value = int_grid[y * map_width + x]-1
			__tile_map.set_cellv(Vector2(x, y), tile_value)
			__tile_map.update_bitmask_area(Vector2(x, y))

	## Add entities to pool
	var entity_instances = data_entity_pool["entityInstances"]
	for j in range(len(entity_instances)):
		var entity_name = entity_instances[j]["__identifier"]
		var entity_scene = get_entity_scene_by_ldtk_identifier(entity_name)
		if entity_scene != null:
			var w = entity_instances[j]["width"]
			var h = entity_instances[j]["height"]
			var pos_x =  entity_instances[j]["px"][0] + w/2
			var pos_y =  entity_instances[j]["px"][1] + h/2
			var entity_instance = spawn_entity(entity_scene, Vector2(pos_x, pos_y))
			if entity_scene == __scene_escape_area:
				var player = spawn_entity(__scene_player, Vector2(pos_x-16, pos_y))
				init_player(player, !__has_check_point)
				__escape_area_ref = entity_instance
				continue
				
			match entity_scene:
				__scene_bomb_switch:
					__bomb_switch_ref = entity_instance
					# The var "bomb_detonation_time" is waaaaay up in this code
					__bomb_switch_ref.set_detonation_time(bomb_detonation_time)
				#__scene_boss_area
				
			continue
		printerr("Unrecognized entity type: ", entity_name)
		
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
	
func hide_and_remove_entities():
#	__geometry.visible = false
	set_remove_all_entities(true)
#	__parallax_sprite.visible = false
	
func set_remove_all_entities(value):
	__remove_all_entities = value

func remove_all_entities():
	return __remove_all_entities

func assign_player_node(player):
	player_node = player

# Retrieve the pixel cell size for the tile map
func get_tile_size():
	return 8
	
func get_theme_enum():
	return __theme_enum

# Instance a node that inherits the base entity scene through a specified scene and
# specify a relative location for the entity to be present. The node is then added as 
# a child of the EntityPool node.
func spawn_entity(entity_scene, location):
	var entity = entity_scene.instance()
	entity.position = location
	entity.parent_world = self
	__entity_pool.add_child(entity)
	return entity
	
func add_geometry(scene, location):
	var geometry = scene.instance()
	geometry.position = location
#	__geometry.add_child(geometry)
	__entity_pool.add_child(geometry)
	return geometry
	
# Instance a node that inherits the base entity scene through a specified scene and
# specify a relative location for the entity to be present. The node is then added as 
# a child of the EntityPool node. The adding is deferred. 
func spawn_entity_deferred(entity_scene, location):
	var entity = entity_scene.instance()
	entity.position = location
	entity.parent_world = self
	__entity_pool.call_deferred("add_child", entity)
	return entity

func get_entity_pool():
	return  __entity_pool

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
		
func _on_sound_can_play(sound):
	__delayed_sounds.erase(sound.stream.resource_path)

func _on_ScrapHoverText_display_off():
	__scrap_recently_collected = 0
	

func _on_DeathPits_body_entered(player):
	player.die()

