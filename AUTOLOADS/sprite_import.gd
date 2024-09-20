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
signal preview_palette_set

signal sprite_import_started
signal sprite_import_finished
signal sprite_placement_started
signal sprite_placement_finished

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
var preview_sprite: BinSprite
var preview_palette_index: int = 0
var preview_palette: PackedByteArray

# Used by this singleton
var obj_data: ObjectData
var pal_data: PaletteData
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

# Multithreading
var waiting_tasks: Array[int] = []

@onready var sprite_importer: SpriteImporter = SpriteImporter.new()


func _ready() -> void:
	sprite_import_finished.connect(import_place_sprites)


func _physics_process(_delta: float) -> void:
	for task in waiting_tasks:
		if WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			waiting_tasks.pop_at(waiting_tasks.find(task))


func import_files(object_name: String) -> void:
	obj_data = SessionData.object_data_get(object_name)
	sprite_import_started.emit(object_name)
	waiting_tasks.append(WorkerThreadPool.add_task(import_files_thread))


func import_files_thread() -> void:
	var sprites: Array[BinSprite] = sprite_importer.import_sprites(
		import_list, embed_palette, halve_alpha, flip_h, flip_v, as_rgb, reindex, bit_depth)
	
	call_deferred("emit_signal", "sprite_import_finished", sprites)


func import_place_sprites(sprites: Array[BinSprite]) -> void:
	sprite_placement_started.emit()
	waiting_tasks.append(
		WorkerThreadPool.add_task(import_place_sprites_thread.bind(sprites)))


func import_place_sprites_thread(sprites: Array[BinSprite]) -> void:
	var data_sprites: Array[BinSprite] = obj_data.sprites
	
	match placement_method:
		PlaceMode.APPEND:
			data_sprites.append_array(sprites)
		
		PlaceMode.REPLACE:
			# "Replacing" at end
			if insert_position == data_sprites.size():
				data_sprites.append_array(sprites)
			
			# Imported sprite count replaces end and extends it
			elif sprites.size() >= data_sprites.size() - insert_position:
				data_sprites.resize(insert_position)
				data_sprites.append_array(sprites)
			
			# Imported sprites replace section in the middle
			else:
				for i in sprites.size():
					data_sprites[insert_position + i] = sprites[i]
		
		PlaceMode.INSERT:
			# Can't insert array, have to do it item by item
			for i in sprites.size():
				data_sprites.insert(
					insert_position, sprites[sprites.size() - i - 1]
				)
	
	call_deferred("emit_signal", "sprite_placement_finished")


func set_preview_sprite_index(index: int) -> void:
	preview_index = index
	generate_preview(preview_index)


func generate_preview(sprite_index: int) -> void:
	if sprite_index >= import_list.size():
		return
	
	preview_sprite = SpriteImporter.import_sprite(
		import_list[sprite_index], embed_palette, halve_alpha,
		flip_h, flip_v, as_rgb, reindex, bit_depth)
	
	preview_palette = pal_data.palettes[preview_palette_index].palette
	
	preview_generated.emit()


func set_preview_palette_index(index: int) -> void:
	preview_palette_index = index
	preview_palette = pal_data.palettes[index].palette
	preview_palette_set.emit()


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
