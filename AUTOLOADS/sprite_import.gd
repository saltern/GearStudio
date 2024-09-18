extends Node

signal files_selected
signal placement_method_set
signal insert_position_set
signal embed_palette_set
signal halve_alpha_set
signal flip_h_set
signal flip_v_set
signal as_rgb_set
signal reindex_set
signal bit_depth_set

signal preview_generated

signal sprite_import_started
signal sprite_import_finished

enum PlaceMode {
	APPEND,
	REPLACE,
	INSERT,
}

enum BitDepth {
	AS_IS,
	FORCE_4_BPP,
	FORCE_8_BPP,
}

# Used by preview
var preview_index: int = 0

# Used by this singleton
var obj_state: ObjectEditState
var import_list: PackedStringArray = []
var placement_method: int
var insert_position: int

# Used by actual importer
var embed_palette: bool = false
var halve_alpha: bool = false
var flip_h: bool = false
var flip_v: bool = false
var as_rgb: bool = false
var reindex: bool = false
var bit_depth: BitDepth = BitDepth.AS_IS


func import_files(object_name: String) -> void:
	sprite_import_started.emit(object_name)
	SpriteImporter.import_sprites(
		import_list, embed_palette, halve_alpha, flip_h, flip_v, as_rgb, reindex, bit_depth)


func set_preview_index(index: int) -> void:
	preview_index = index
	generate_preview(preview_index)


func generate_preview(sprite_index: int) -> void:
	if sprite_index >= import_list.size():
		return
	
	preview_generated.emit(
		SpriteImporter.import_sprite(
			import_list[sprite_index], embed_palette, halve_alpha,
			flip_h, flip_v, as_rgb, reindex, bit_depth
		)
	)


func select_files(files: PackedStringArray) -> void:
	import_list = files
	files_selected.emit()
	preview_index = 0
	generate_preview(preview_index)


func set_placement_method(mode: PlaceMode) -> void:
	placement_method = mode
	placement_method_set.emit()


func set_insert_position(position: int) -> void:
	insert_position = position
	insert_position_set.emit()


func set_embed_palette(enabled: bool) -> void:
	embed_palette = enabled
	embed_palette_set.emit()
	generate_preview(preview_index)


func set_halve_alpha(enabled: bool) -> void:
	halve_alpha = enabled
	halve_alpha_set.emit()
	generate_preview(preview_index)


func set_flip_h(enabled: bool) -> void:
	flip_h = enabled
	flip_h_set.emit()
	generate_preview(preview_index)


func set_flip_v(enabled: bool) -> void:
	flip_v = enabled
	flip_v_set.emit()
	generate_preview(preview_index)


func set_as_rgb(enabled: bool) -> void:
	as_rgb = enabled
	as_rgb_set.emit()
	generate_preview(preview_index)


func set_reindex(enabled: bool) -> void:
	reindex = enabled
	reindex_set.emit()
	generate_preview(preview_index)


func set_bit_depth(mode: BitDepth) -> void:
	bit_depth = mode
	bit_depth_set.emit()
	generate_preview(preview_index)
