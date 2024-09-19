extends Node

enum AlphaMode {
	AS_IS,
	DOUBLE,
	HALVE,
	OPAQUE,
}

var export_bin: bool = false
var export_raw: bool = false
var export_png: bool = false
var export_bmp: bool = false

var export_list: Array[BinSprite] = []
var export_start_index: int = 0
var export_end_index: int = 0

var palette_index: int = 0
var palette_include: bool = false
var palette_override: bool = false
var palette_alpha_mode: AlphaMode = AlphaMode.AS_IS

var sprite_reindex: bool = false
var name_from_zero: bool = false

var obj_data: ObjectData
var pal_data: PaletteData

var pal_gray: PackedByteArray


func _ready() -> void:
	for index in 256:
		pal_gray.append(index)
		pal_gray.append(index)
		pal_gray.append(index)
		pal_gray.append(0xFF)


func export(output_path: String) -> void:
	export_list.clear()
	
	for sprite_index in range(export_start_index, export_end_index + 1):
		export_list.append(obj_data.sprites[sprite_index])
	
	var name_start_index: int = 0
	if not name_from_zero:
		name_start_index = export_start_index
	
	var palette: PackedByteArray = pal_gray
	
	if palette_include:
		palette = pal_data.palettes[palette_index].palette
	
	if export_bin:
		var bin_palette_include: bool = palette_include
		
		if palette == pal_gray:
			bin_palette_include = false
		
		SpriteExporter.export_sprites(
			"bin",
			output_path,
			export_list,
			name_start_index,
			bin_palette_include,
			palette,
			palette_alpha_mode,
			palette_override,
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
			palette_override,
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
			palette_override,
			sprite_reindex)
