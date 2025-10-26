extends SteppingSpinBox


func _ready() -> void:
	visibility_changed.connect(update)
	value_changed.connect(update.unbind(1))
	
	var session_id: int = get_owner().session_id
	var palette_count: int = SessionData.session_get_palettes(session_id).size()
	max_value = palette_count - 1


func update() -> void:
	SpriteExport.set_palette_index(value)
