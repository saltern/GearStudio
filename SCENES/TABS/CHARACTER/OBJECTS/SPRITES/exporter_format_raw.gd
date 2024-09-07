extends CheckButton


func _ready() -> void:
	toggled.connect(on_format_raw_toggle)


func on_format_raw_toggle(enabled: bool) -> void:
	SpriteExport.export_raw = enabled
