extends SteppingSpinBox

@onready var sprite_edit: SpriteEdit = owner


func _ready() -> void:
	if not sprite_edit.with_palettes:
		get_parent().queue_free()
		return
	
	max_value = sprite_edit.pal_data.get_sprite_count() - 1
	
	value_changed.connect(SessionData.set_palette)
	
	if sprite_edit.with_palettes:
		SessionData.palette_changed.connect(external_update_value)


func external_update_value(for_session: int, index: int) -> void:
	if for_session != sprite_edit.session_id:
		return
	
	call_deferred("set_value_no_signal", index)
