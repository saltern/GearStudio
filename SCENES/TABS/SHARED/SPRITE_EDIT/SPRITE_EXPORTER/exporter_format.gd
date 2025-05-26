extends CheckButton

enum ExportFormat {
	BIN,
	BIN_UNCOMPRESSED,
	RAW,
	PNG,
	BMP,
}

@export var export_format: ExportFormat = 0


func _ready() -> void:
	toggled.connect(on_format_toggled)


func on_format_toggled(enabled: bool) -> void:
	match export_format:
		ExportFormat.BIN:
			SpriteExport.export_bin = enabled
		ExportFormat.BIN_UNCOMPRESSED:
			SpriteExport.export_bin_u = enabled
		ExportFormat.RAW:
			SpriteExport.export_raw = enabled
		ExportFormat.PNG:
			SpriteExport.export_png = enabled
		ExportFormat.BMP:
			SpriteExport.export_bmp = enabled
