# Palette selector for the SpriteEditor.
extends SteppingSpinBox

@onready var editor: SpriteEditor = owner
@onready var session: Session = editor.session


func _ready() -> void:
	if not editor.object_has_palettes():
		get_parent().queue_free()
		return
	
	max_value = editor.get_palette_count() - 1


func _value_changed(new_value: float) -> void:
	session.set_palette(int(new_value))
