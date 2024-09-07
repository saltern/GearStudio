extends CheckButton


func _ready() -> void:
	toggled.connect(on_palette_include_toggled)


func on_palette_include_toggled(enabled: bool) -> void:
	SpriteExport.palette_include = enabled
