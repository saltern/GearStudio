extends CheckButton


func _ready() -> void:
	toggled.connect(on_format_bmp_toggle)


func on_format_bmp_toggle(enabled: bool) -> void:
	SpriteExport.export_bmp = enabled
