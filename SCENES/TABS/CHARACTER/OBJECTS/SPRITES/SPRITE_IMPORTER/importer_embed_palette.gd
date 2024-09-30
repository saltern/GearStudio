extends CheckButton


func _ready() -> void:
	toggled.connect(update)
	visibility_changed.connect(on_display)
	
	if not get_owner().obj_data.has_palettes():
		button_pressed = true


func on_display() -> void:
	if visible:
		update(button_pressed)


func update(enabled: bool) -> void:
	SpriteImport.set_embed_palette(enabled)
