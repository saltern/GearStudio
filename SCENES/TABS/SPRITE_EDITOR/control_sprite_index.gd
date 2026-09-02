# Sprite selector for the SpriteEditor.
extends SteppingSpinBox

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	editor.sprite_forced.connect(force_update)
	max_value = editor.get_sprite_count() - 1


func _value_changed(new_value: float) -> void:
	editor.set_sprite(new_value)


func force_update(new_value: int) -> void:
	set_value_no_signal(new_value)
