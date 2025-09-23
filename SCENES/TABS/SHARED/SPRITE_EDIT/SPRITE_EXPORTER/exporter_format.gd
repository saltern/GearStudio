extends CheckButton

enum ExportFormat {
	BIN,
	BIN_UNCOMPRESSED,
	RAW,
	PNG,
	BMP,
}

@export var export_format: ExportFormat = ExportFormat.BIN


func _ready() -> void:
	toggled.connect(on_format_toggled)


func on_format_toggled(enabled: bool) -> void:
	match export_format:
		ExportFormat.BIN:
			SpriteExport.settings.export_bin = enabled
		ExportFormat.BIN_UNCOMPRESSED:
			SpriteExport.settings.export_bin_uncompressed = enabled
		ExportFormat.RAW:
			SpriteExport.settings.export_raw = enabled
		ExportFormat.PNG:
			SpriteExport.settings.export_png = enabled
		ExportFormat.BMP:
			SpriteExport.settings.export_bmp = enabled
