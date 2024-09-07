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

var obj_state: ObjectEditState
var pal_state: PaletteEditState

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
		export_list.append(obj_state.sprite_get(sprite_index))
	
	var name_start_index: int = 0
	if not name_from_zero:
		name_start_index = export_start_index
	
	var palette: PackedByteArray = pal_gray
	
	if palette_include:
		palette = pal_state.get_palette_colors(palette_index)
	
	if export_png:
		SpriteExporter.export_sprites_png(
			output_path,
			export_list,
			name_start_index,
			palette,
			palette_alpha_mode,
			sprite_reindex)
