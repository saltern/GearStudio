extends CheckButton


func _ready() -> void:
	toggled.connect(on_palette_override_toggled)


func on_palette_override_toggled(enabled: bool) -> void:
	SpriteExport.palette_override = enabled
