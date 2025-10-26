extends Node

@warning_ignore("unused_signal")
signal hide_exporter_windows	# Used by exporter_window.gd
signal export_start_index_set
signal export_end_index_set
signal palette_index_set
signal palette_include_set
signal palette_alpha_mode_set
signal palette_reindex_set
signal sprite_reindex_set
signal sprite_flip_h_set
signal sprite_flip_v_set

enum AlphaMode {
	AS_IS,
	DOUBLE,
	HALVE,
	OPAQUE,
}

var preview_index: int = 0
var preview_sprite: BinSprite

var palette_index: int = 0

var export_list: Array[BinSprite] = []
var export_start_index: int = 0
var export_end_index: int = 0
var export_start_from_zero: bool = false

var obj_data: Dictionary

var pal_gray: PackedByteArray

var settings := SpriteExporterSettings.new()
# export_bin
# export_bin_uncompressed
# export_raw
# export_png
# export_bmp

# palette_include
# palette_alpha_mode
# palette_reindex

# sprite_reindex
# sprite_flip_h
# sprite_flip_v

# file_name_from_zero
# file_name_zero_pad


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
	settings.palette_include = enabled
	palette_include_set.emit()


func set_palette_alpha_mode(mode: AlphaMode) -> void:
	settings.palette_alpha_mode = mode
	palette_alpha_mode_set.emit()


func set_palette_reindex(enabled: bool) -> void:
	settings.palette_reindex = enabled
	palette_reindex_set.emit()


func set_sprite_reindex(enabled: bool) -> void:
	settings.sprite_reindex = enabled
	sprite_reindex_set.emit()


func set_sprite_flip_h(enabled: bool) -> void:
	settings.sprite_flip_h = enabled
	sprite_flip_h_set.emit()


func set_sprite_flip_v(enabled: bool) -> void:
	settings.sprite_flip_v = enabled
	sprite_flip_v_set.emit()


func set_name_from_zero(enabled: bool) -> void:
	export_start_from_zero = enabled
	
	if enabled:
		settings.file_name_start_index = 0
	else:
		settings.file_name_start_index = export_start_index


func set_name_zero_pad(enabled: bool) -> void:
	settings.file_name_zero_pad = enabled


func get_palette_included() -> bool:
	return settings.palette_include


func get_palette_reindex() -> bool:
	return settings.palette_reindex


func get_sprite_reindex() -> bool:
	return settings.sprite_reindex


func get_sprite_flip_h() -> bool:
	return settings.sprite_flip_h


func get_sprite_flip_v() -> bool:
	return settings.sprite_flip_v


func export(output_path: String) -> void:
	export_list.clear()
	
	for sprite_index in range(export_start_index, export_end_index + 1):
		export_list.append(obj_data.sprites[sprite_index])

	var palette: PackedByteArray = pal_gray
	
	if settings.palette_include and obj_data.has("palettes"):
		settings.palette_colors = obj_data["palettes"][palette_index].palette
	
	settings.palette_override = obj_data.has("palettes")
	set_name_from_zero(export_start_from_zero)
	
	SpriteExporter.export_sprites(export_list, output_path, settings)
