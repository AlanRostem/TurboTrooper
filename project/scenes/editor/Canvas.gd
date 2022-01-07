extends Control

onready var __level = $Level

var __canvas_tool

func _ready():
	set_paused(true)
	set_canvas_tool(PencilTool.new())
	__canvas_tool.set_entity_stroke(load("res://scenes/game/level/entity/entities/collectible/CollectibleBomb.tscn"))

func _gui_input(event):
#################################################
#	Floor entities can have a diffrent z index	#
#################################################
	if event.is_action("editor_add"):
		__canvas_tool.set_place(event.is_pressed())
		
#		add_entity(load("res://scenes/game/level/entity/entities/collectible/CollectibleBomb.tscn"), __position_to_tile(get_local_mouse_position()))
#		set_tile(position_to_tile(get_local_mouse_position()), 2)
#		add_entity(load("res://scenes/game/level/entity/entities/test_entity/TestEntity.tscn"), __position_to_tile(get_local_mouse_position()))
	
	if event.is_action("editor_remove"):
		__canvas_tool.set_remove(event.is_pressed())
		
#		remove_tile_or_entity_at_tile(position_to_tile(get_local_mouse_position()))
	
	if event.is_action("editor_pause"):
		set_paused(!is_paused())
		
func _process(delta):
	if Input.is_action_just_pressed("editor_pause"):
		save()

func is_paused():
	return get_tree().paused

func set_paused(flag):
	get_tree().paused = flag

func get_entity_at_tile(tile):
	var tile_size = __level.get_game_world().get_tile_size()
	for idx in range(get_entities().size() - 1, -1, -1):
		var entity = get_entities()[idx]
		if tile == position_to_tile(entity.position): 
			return entity
	return null

func get_tile(tile):
	return __level.get_game_world().get_entity_pool().get_cellv(tile)

func add_entity(scene, tile):
	if is_tile_occupied(tile): return
	__level.get_game_world().spawn_entity(scene, tile_to_position(tile))

func get_entities():
	var entities = __level.get_game_world().get_entity_pool().get_children()
	entities.append_array(__level.get_game_world().get_floor_entity_pool().get_children())
	return entities

func set_tile(type, tile):
	if get_tile(tile) != -1 or get_entity_at_tile(tile) != null: return
	__level.get_game_world().get_entity_pool().set_cellv(tile, type)
	__level.get_game_world().get_entity_pool().update_bitmask_area(tile)

func remove_entity(entity):
	entity.queue_free()

func remove_tile(tile):
	__level.get_game_world().get_entity_pool().set_cellv(tile, -1)
	__level.get_game_world().get_entity_pool().update_bitmask_area(tile)

func remove_tile_or_entity_at_tile(tile):
	var entity = get_entity_at_tile(tile)
	if entity != null:
		remove_entity(entity)
	elif get_tile(tile) != -1:
		remove_tile(tile)
		return

func set_canvas_tool(canvas_tool):
	var stroke = null
	if __canvas_tool != null:
		remove_child(__canvas_tool)
		stroke = __canvas_tool.get_entity_stroke()
		if stroke == null:
			stroke = __canvas_tool.get_tile_stroke()
		__canvas_tool.queue_free()
	__canvas_tool = canvas_tool
	add_child(__canvas_tool)
	if stroke is int:
		stroke = __canvas_tool.set_tile_stroke(stroke)
	elif stroke is Object:
		stroke = __canvas_tool.set_entity_stroke(stroke)

func get_canvas_tool():
	return __canvas_tool

func position_to_tile(pos):
	var tile_size = __level.get_game_world().get_tile_size()
	return (pos / tile_size).floor()

func tile_to_position(tile):
	var tile_size = __level.get_game_world().get_tile_size()
	return tile * tile_size + Vector2.ONE * tile_size / 2

func is_tile_occupied(tile):
	return get_tile(tile) != -1 or get_entity_at_tile(tile) != null

func save():
	var scene = PackedScene.new()
	var scene_root = __level
	scene.pack(scene_root)
	ResourceSaver.save('res://test.tscn', scene)
	
func __set_owner(node, root):
	if node != root:
		node.owner = root
	for child in node.get_children():
		__set_owner(child, root)
