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
	visibility_changed.connect(update)
	

func _toggled(toggled_on: bool) -> void:
	match export_format:
		ExportFormat.BIN:
			SpriteExport.settings.export_bin = toggled_on
		ExportFormat.BIN_UNCOMPRESSED:
			SpriteExport.settings.export_bin_uncompressed = toggled_on
		ExportFormat.RAW:
			SpriteExport.settings.export_raw = toggled_on
		ExportFormat.PNG:
			SpriteExport.settings.export_png = toggled_on
		ExportFormat.BMP:
			SpriteExport.settings.export_bmp = toggled_on


func update() -> void:
	if visible:
		_toggled(button_pressed)
