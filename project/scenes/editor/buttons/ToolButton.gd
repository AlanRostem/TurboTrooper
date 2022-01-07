extends TextureButton

export(Script) var __tool = null


onready var __editor = get_parent().get_parent().get_parent().get_parent()
onready var __frame = $TextureFrame

func _on_ToolButton_toggled(button_pressed):
	if button_pressed:
		__editor.get_editor_canvas().set_canvas_tool(__tool.new())
	__frame.visible = button_pressed
