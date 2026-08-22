# Sprite selector for the SpriteEditor.
extends SteppingSpinBox

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	max_value = editor.get_sprite_count() - 1
