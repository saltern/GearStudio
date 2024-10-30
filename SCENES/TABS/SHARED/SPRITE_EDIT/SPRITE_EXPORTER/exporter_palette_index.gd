extends SteppingSpinBox


func _ready() -> void:
	visibility_changed.connect(update)
	value_changed.connect(update.unbind(1))


func update() -> void:
	SpriteExport.set_palette_index(value)
