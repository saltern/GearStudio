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

var obj_data: BinObject

var pal_gray: PackedByteArray

#var settings := SpriteExporterSettings.new()
var export_bin: bool = false
var export_bin_uncompressed: bool = false
var export_raw: bool = false
var export_png: bool = false
var export_bmp: bool = false

var palette: PackedByteArray
var palette_include: bool = false
var palette_alpha_mode: AlphaMode = AlphaMode.AS_IS
var palette_reindex: bool = false

var sprite_reindex: bool = false
var sprite_flip_h: bool = false
var sprite_flip_v: bool = false

var file_name_start_index: int = 0
var file_name_from_zero: bool = false
var file_name_zero_pad: bool = false


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


func set_palette_reindex(enabled: bool) -> void:
	palette_reindex = enabled
	palette_reindex_set.emit()


func set_sprite_reindex(enabled: bool) -> void:
	sprite_reindex = enabled
	sprite_reindex_set.emit()


func set_sprite_flip_h(enabled: bool) -> void:
	sprite_flip_h = enabled
	sprite_flip_h_set.emit()


func set_sprite_flip_v(enabled: bool) -> void:
	sprite_flip_v = enabled
	sprite_flip_v_set.emit()


func set_name_from_zero(enabled: bool) -> void:
	export_start_from_zero = enabled
	
	if enabled:
		file_name_start_index = 0
	else:
		file_name_start_index = export_start_index


func set_name_zero_pad(enabled: bool) -> void:
	file_name_zero_pad = enabled


func get_palette_included() -> bool:
	return palette_include


func get_palette_reindex() -> bool:
	return palette_reindex


func get_sprite_reindex() -> bool:
	return sprite_reindex


func get_sprite_flip_h() -> bool:
	return sprite_flip_h


func get_sprite_flip_v() -> bool:
	return sprite_flip_v


func export(path: String) -> void:
	export_list.clear()
	
	for sprite_index in range(export_start_index, export_end_index + 1):
		export_list.append(obj_data.sprites[sprite_index])
	
	set_name_from_zero(file_name_from_zero)
	
	# Preprocessing
	var processed_array: Array[BinSprite] = []
	
	for sprite: BinSprite in export_list:
		var new_sprite: BinSprite = sprite.duplicate(true)
		processed_array.append(new_sprite)
		
		if not palette_include:
			new_sprite.purge_palette()
			palette = pal_gray
		else:
			# Player objects
			if obj_data.has("palettes"):
				palette = obj_data.get_palette(palette_index)
			
			# Embedded palettes
			if palette.is_empty():
				palette = new_sprite.palette
			
			# Fallback
			if palette.is_empty():
				palette = pal_gray
			
			# Palette operations
			match palette_alpha_mode:
				AlphaMode.AS_IS:
					pass
				AlphaMode.DOUBLE:
					new_sprite.palette_double_alpha()
				AlphaMode.HALVE:
					new_sprite.palette_halve_alpha()
				AlphaMode.OPAQUE:
					new_sprite.palette_make_opaque()
			
			if palette_reindex:
				new_sprite.reindex_palette()
		
		# Sprite operations
		if sprite_reindex:
			new_sprite.reindex_pixels()
		
		if sprite_flip_h:
			new_sprite.flip_h()
		
		if sprite_flip_v:
			new_sprite.flip_v()
		
	var index: int = file_name_start_index
	
	for sprite: BinSprite in processed_array:
		if export_bin:
			var bin_file: FileAccess = FileAccess.open(
				"%s/sprite_%s.bin" % [path, index], FileAccess.WRITE
			)
			
			bin_file.store_buffer(sprite.serialize())
			bin_file.close()
		
		if export_bin_uncompressed:
			var bin_file: FileAccess = FileAccess.open(
				"%s/u_sprite_%s.bin" % [path, index], FileAccess.WRITE
			)
			
			var old_mode: BinSprite.Mode = sprite.mode
			sprite.mode = BinSprite.Mode.RAW
			
			bin_file.store_buffer(sprite.serialize())
			bin_file.close()
			
			sprite.mode = old_mode
		
		if export_raw:
			var file_path: String = "%s/sprite_%s-W-%s-H-%s.raw" % [
				path, index, sprite.width, sprite.height
			]
			
			var raw_file: FileAccess = FileAccess.open(
				file_path, FileAccess.WRITE
			)
			
			raw_file.store_buffer(sprite.pixels)
		
		if export_bmp:
			var file_path: String = "%s/sprite_%s.bmp" % [path, index]
			
			SpriteExporter.make_bmp(
				file_path, sprite.pixels, sprite.width, sprite.height,
				sprite.bit_depth, palette, false, false, false, false
			)
		
		if export_png:
			var file_path: String = "%s/sprite_%s.png" % [path, index]
			
			SpriteExporter.make_png(
				file_path, sprite.pixels, sprite.width, sprite.height,
				sprite.bit_depth, palette, 0, false, false, false, false
			)
		
		index += 1
