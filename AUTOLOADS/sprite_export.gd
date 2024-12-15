extends Node

@warning_ignore("unused_signal")
signal hide_exporter_windows	# Used by exporter_window.gd
signal export_start_index_set
signal export_end_index_set
signal palette_index_set
signal palette_include_set
signal palette_alpha_mode_set
signal sprite_reindex_set

enum AlphaMode {
	AS_IS,
	DOUBLE,
	HALVE,
	OPAQUE,
}

var preview_index: int = 0
var preview_sprite: BinSprite

var export_bin: bool = false
var export_raw: bool = false
var export_png: bool = false
var export_bmp: bool = false

var export_list: Array[BinSprite] = []
var export_start_index: int = 0
var export_end_index: int = 0

var palette_index: int = 0
var palette_include: bool = false
var palette_alpha_mode: AlphaMode = AlphaMode.AS_IS

var sprite_reindex: bool = false
var name_from_zero: bool = false

var obj_data: Dictionary

var pal_gray: PackedByteArray


func _ready() -> void:
	for index in 256:
		pal_gray.append(index)
		pal_gray.append(index)
		pal_gray.append(index)
		pal_gray.append(0xFF)


func set_preview_index(index: int) -> void:
	preview_index = index


func set_export_start_index(index: int) -> void:
	export_start_index = index
	export_start_index_set.emit()


func set_export_end_index(index: int) -> void:
	export_end_index = index
	export_end_index_set.emit()


func set_palette_index(index: int) -> void:
	palette_index = index
	palette_index_set.emit()


func set_palette_include(enabled: bool) -> void:
	palette_include = enabled
	palette_include_set.emit()


func set_palette_alpha_mode(mode: AlphaMode) -> void:
	palette_alpha_mode = mode
	palette_alpha_mode_set.emit()


func set_sprite_reindex(enabled: bool) -> void:
	sprite_reindex = enabled
	sprite_reindex_set.emit()


func set_name_from_zero(enabled: bool) -> void:
	name_from_zero = enabled


func export(output_path: String) -> void:
	export_list.clear()
	
	for sprite_index in range(export_start_index, export_end_index + 1):
		export_list.append(obj_data.sprites[sprite_index])
	
	var name_start_index: int = 0 if name_from_zero else export_start_index
	var palette: PackedByteArray = pal_gray
	
	if palette_include:
		palette = obj_data["palettes"][palette_index].palette
	
	if export_bin:
		SpriteExporter.export_sprites(
			"bin",
			output_path,
			export_list,
			name_start_index,
			palette_include,
			palette,
			palette_alpha_mode,
			obj_data.has("palettes"),
			sprite_reindex)
	
	if export_raw:
		SpriteExporter.export_sprites(
			"raw",
			output_path,
			export_list,
			name_start_index,
			# v Ignored
			false,
			PackedByteArray([]),
			AlphaMode.AS_IS,
			false,
			# ^ Ignored
			sprite_reindex)
	
	if export_png:
		SpriteExporter.export_sprites(
			"png",
			output_path,
			export_list,
			name_start_index,
			palette_include,
			palette,
			palette_alpha_mode,
			obj_data.has("palettes"),
			sprite_reindex)

	if export_bmp:
		SpriteExporter.export_sprites(
			"bmp",
			output_path,
			export_list,
			name_start_index,
			palette_include,
			palette,
			palette_alpha_mode,
			obj_data.has("palettes"),
			sprite_reindex)


func export_select(sprite: BinSprite, path: String) -> void:
	SpriteExporter.export_sprites(
		"png", path, [sprite],
		0,
		false,
		pal_gray,
		AlphaMode.OPAQUE,
		false,
		false
	)
