extends SteppingSpinBox

@export var dialog: SpriteImportDialog


func _ready() -> void:
	dialog.session_set.connect(check_editable.unbind(2))


func _value_changed(new_value: float) -> void:
	dialog.set_palette_override(new_value)


func check_editable() -> void:
	max_value = dialog.get_palette_count()
	editable = max_value > 0
