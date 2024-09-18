extends CheckButton


func _ready() -> void:
	toggled.connect(on_format_bin_toggle)


func on_format_bin_toggle(enabled: bool) -> void:
	SpriteExport.export_bin = enabled
