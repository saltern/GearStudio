extends CheckButton


func _ready() -> void:
	toggled.connect(on_format_png_toggle)


func on_format_png_toggle(enabled: bool) -> void:
	SpriteExport.export_png = enabled
