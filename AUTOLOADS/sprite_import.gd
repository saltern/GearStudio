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
var regenerate_preview: bool = false

# Used by this singleton
var undo_redo: UndoRedo
var obj_data: Dictionary
var obj_name: String
var import_list: PackedStringArray = []
var placement_method: int
var insert_position: int
var place_by_filename: bool = false
var import_order: PackedInt32Array

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
	Handshake.status = true


func _physics_process(_delta: float) -> void:
	for task in waiting_tasks:
		if WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			waiting_tasks.pop_at(waiting_tasks.find(task))

	if regenerate_preview:
		generate_preview(preview_index)


# Undo/Redo status shorthand
func status_register_action(action_text: String) -> void:
	undo_redo.add_do_method(Status.set_status.call_deferred.bind(action_text))
	undo_redo.add_undo_method(Status.set_status.call_deferred.bind(
		tr("ACTION_UNDO").format({
			"action": action_text
		}
	)))


func import_file_direct(path: String) -> BinSprite:
	return SpriteImporter.import_sprite(
		path, false, false, false, false, false, false, 8)


# First step after hitting OK to import
func import_files(object_data: Dictionary) -> void:
	obj_data = object_data
	sprite_import_started.emit()
	waiting_tasks.append(WorkerThreadPool.add_task(import_files_thread))


# Actual worker for above
func import_files_thread() -> void:
	var sprites: Array[BinSprite] = sprite_importer.import_sprites(
		import_list, embed_palette, halve_alpha,
		flip_h, flip_v, as_rgb, reindex, bit_depth)
	
	call_deferred("emit_signal", "sprite_import_finished", sprites)


# Second step after import finished into sprite array
func import_place_sprites(sprites: Array[BinSprite]) -> void:
	sprite_placement_started.emit()
	waiting_tasks.append(
		WorkerThreadPool.add_task(import_place_sprites_thread.bind(sprites)))


# Actual worker for above
func import_place_sprites_thread(sprites: Array[BinSprite]) -> void:
	var data_sprites: Array[BinSprite] = obj_data["sprites"]
	
	# Can't use tr from a worker thread, keep as-is
	var action_text: String = TranslationServer.translate(
		"ACTION_SPRITE_IMPORTER_IMPORT").format({
			"count": sprites.size(),
			"object": obj_name
		}
	)
	
	undo_redo.create_action(action_text)
	
	match placement_method:
		PlaceMode.APPEND:
			var old_size: int = data_sprites.size()
			
			undo_redo.add_do_method(
				import_append_sprites.bind(sprites))
			undo_redo.add_undo_method(
				import_resize_sprites.bind(obj_data, old_size))
		
		PlaceMode.REPLACE:
			# Import at locations defined by file name
			if place_by_filename:
				for index in sprites.size():
					var replace_at: int = import_order[index]
					
					undo_redo.add_do_method(
						import_replace_sprite.bind(
							data_sprites, replace_at, sprites[index]
						)
					)
					
					undo_redo.add_undo_method(
						import_replace_sprite.bind(
							data_sprites, replace_at, data_sprites[replace_at]
						)
					)
					
			else:
				import_place_sprites_replace(data_sprites, sprites)
		
		PlaceMode.INSERT:
			var l_side: Array[BinSprite] = data_sprites.slice(
				0, insert_position)
			var r_side: Array[BinSprite] = data_sprites.slice(
				insert_position, data_sprites.size())
			
			var new_sprites: Array[BinSprite] = []
			new_sprites.append_array(l_side)
			new_sprites.append_array(sprites)
			new_sprites.append_array(r_side)
			
			undo_redo.add_do_method(import_set_sprites.bind(new_sprites))
			undo_redo.add_undo_method(import_set_sprites.bind(data_sprites))
	
	# Directly emitting from here doesn't work for some reason
	undo_redo.add_do_method(import_placement_done)
	undo_redo.add_undo_method(import_placement_done)
	
	undo_redo.add_do_method(import_set_status.bind(action_text))
	undo_redo.add_undo_method(import_set_status.bind(action_text, true))
	undo_redo.commit_action()


func import_place_sprites_replace(
	data_sprites: Array[BinSprite], sprites: Array[BinSprite]
) -> void:
	# "Replacing" at end
	if insert_position == data_sprites.size():
		var old_size: int = data_sprites.size()
		
		undo_redo.add_do_method(
			import_append_sprites.bind(sprites))
		undo_redo.add_undo_method(
			import_resize_sprites.bind(obj_data, old_size))
	
	# Imported sprite count replaces end and extends it
	elif sprites.size() >= data_sprites.size() - insert_position:
		var old_array: Array[BinSprite] = []
		
		for sprite in data_sprites.size() - insert_position:
			old_array.append(data_sprites[insert_position + sprite])
		
		undo_redo.add_do_method(
			import_resize_sprites.bind(obj_data, insert_position))
		undo_redo.add_do_method(import_append_sprites.bind(sprites))
		
		undo_redo.add_undo_method(
			import_resize_sprites.bind(obj_data, insert_position))
		undo_redo.add_undo_method(import_append_sprites.bind(old_array))
	
	# Imported sprites replace section in the middle
	else:
		var l_side: Array[BinSprite] = data_sprites.slice(
			0, insert_position)
		var r_side: Array[BinSprite] = data_sprites.slice(
			insert_position + sprites.size(), data_sprites.size())
		
		var new_sprites: Array[BinSprite] = []
		new_sprites.append_array(l_side)
		new_sprites.append_array(sprites)
		new_sprites.append_array(r_side)
		
		undo_redo.add_do_method(import_set_sprites.bind(new_sprites))
		undo_redo.add_undo_method(import_set_sprites.bind(data_sprites))


func import_set_sprites(sprites: Array[BinSprite]) -> void:
	obj_data["sprites"] = sprites


func import_resize_sprites(data: Dictionary, new_size: int) -> void:
	data.sprites.resize(new_size)


func import_append_sprites(new_sprites: Array[BinSprite]) -> void:
	obj_data.sprites.append_array(new_sprites)


func import_replace_sprite(
	array: Array[BinSprite], at: int, with: BinSprite
) -> void:
	at = clampi(at, 0, array.size() - 1)
	array[at] = with


func import_placement_done() -> void:
	sprite_placement_finished.emit.call_deferred()


func import_set_status(text: String, undo: bool = false) -> void:
	if undo:
		text = TranslationServer.translate("ACTION_UNDO").format({
			"action": text
		})
	
	Status.set_status.bind(text).call_deferred()


func get_preview_sprite_path() -> String:
	if import_list.size() > preview_index:
		return import_list[preview_index]
	else:
		return "(No file)"


func set_preview_sprite_index(index: int) -> void:
	preview_index = index
	regenerate_preview = true


func generate_preview(sprite_index: int) -> void:
	regenerate_preview = false
	
	if sprite_index >= import_list.size():
		preview_sprite = BinSprite.new()
		preview_generated.emit()
		return
	
	preview_sprite = SpriteImporter.import_sprite(
		import_list[sprite_index], embed_palette, halve_alpha,
		flip_h, flip_v, as_rgb, reindex, bit_depth)
	
	if obj_data.has("palettes"):
		preview_palette = obj_data["palettes"][preview_palette_index].palette
	else:
		if preview_sprite:
			preview_palette = preview_sprite.palette
		else:
			preview_palette = PackedByteArray([])
	
	preview_generated.emit()


func set_preview_palette_index(index: int) -> void:
	preview_palette_index = index
	
	if obj_data.has("palettes"):
		preview_palette = obj_data["palettes"][index].palette
		preview_palette_set.emit()


func select_files(files: PackedStringArray) -> void:
	import_order.clear()
	
	for file in files:
		import_order.append(file.to_int())
	
	import_list = files
	files_selected.emit()
	preview_index = 0
	regenerate_preview = true


func set_placement_method(mode: PlaceMode) -> void:
	placement_method = mode
	placement_method_set.emit()


func set_insert_position(position: int) -> void:
	insert_position = position
	insert_position_set.emit()


func set_embed_palette(enabled: bool) -> void:
	embed_palette = enabled
	embed_palette_set.emit()
	regenerate_preview = true


func set_halve_alpha(enabled: bool) -> void:
	halve_alpha = enabled
	halve_alpha_set.emit()
	regenerate_preview = true


func set_flip_h(enabled: bool) -> void:
	flip_h = enabled
	flip_h_set.emit()
	regenerate_preview = true


func set_flip_v(enabled: bool) -> void:
	flip_v = enabled
	flip_v_set.emit()
	regenerate_preview = true


func set_as_rgb(enabled: bool) -> void:
	as_rgb = enabled
	as_rgb_set.emit()
	regenerate_preview = true


func set_reindex(enabled: bool) -> void:
	reindex = enabled
	reindex_set.emit()
	regenerate_preview = true


func set_bit_depth(mode: BitDepth) -> void:
	bit_depth = mode
	bit_depth_set.emit()
	regenerate_preview = true
