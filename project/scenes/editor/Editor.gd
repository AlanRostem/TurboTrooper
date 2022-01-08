extends Control


onready var __canvas = $Canvas
onready var __tiles = $MenuLayer/Tiles
onready var __entities = $MenuLayer/Entities
onready var __tools = $MenuLayer/Tools
onready var __camera = $Canvas/CameraHolder/Camera2D
onready var __file_dialog = $MenuLayer/FileDialog



func get_editor_canvas():
	return __canvas

func _on_PauseButton_pressed():
	get_tree().paused = !get_tree().paused

func save(path: String):
	var level = __canvas.get_level()
	level.player_node.set_camera_follow(true)
	var scene_root = level
	__set_owner(scene_root, scene_root)
	var scene = PackedScene.new()
	scene.pack(scene_root)
	ResourceSaver.save(path, scene)
	level.player_node.set_camera_follow(false)
	
func load_level(path: String):
	var scene = load(path)
	__canvas.set_level(scene.instance())

func __set_owner(node, root):
	if node != root:
		node.owner = root
	for child in node.get_children():
		if !__is_instanced_from_scene(child):
			__set_owner(child, root)
		else:
			child.owner = root
		
func __is_instanced_from_scene(node):
	return !node.filename.empty()

func _on_SaveButton_pressed():
	__file_dialog.mode = FileDialog.MODE_SAVE_FILE
	__file_dialog.popup()

func _on_LoadButton_pressed():
	__file_dialog.mode = FileDialog.MODE_OPEN_FILE
	__file_dialog.popup()
	
func _on_FileDialog_file_selected(path):
	match __file_dialog.mode:
		FileDialog.MODE_SAVE_FILE:
			save(path)
		FileDialog.MODE_OPEN_FILE:
			load_level(path)
