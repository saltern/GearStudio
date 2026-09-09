extends CheckButton

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	if editor.object_has_palettes():
		button_pressed = true
		disabled = true
