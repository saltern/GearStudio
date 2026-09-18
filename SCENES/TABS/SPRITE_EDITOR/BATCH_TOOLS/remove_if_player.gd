extends Control

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	if editor.object_has_palettes():
		hide()
		queue_free()
