class_name SpriteImportDialog extends BasicDialog

signal session_set
signal files_set
signal placement_method_set
signal placement_manual_range_set
signal placement_by_filename_set
signal palette_embed_set
signal palette_half_size_set
signal palette_half_alpha_set
signal palette_reindex_set
signal sprite_flip_h_set
signal sprite_flip_v_set
signal sprite_as_rgb_set
signal sprite_reindex_set
signal sprite_bit_depth_set

signal sprite_imported
signal sprite_processed
signal all_sprites_processed
signal sprite_placed

signal sprite_range_changed

enum PlacementMethod {
	APPEND,
	INSERT,
	REPLACE,
}

enum BitDepthMode {
	NO_CHANGE,
	SET_TO_4,
	SET_TO_8,
}

@export var files_browser: FileDialog
@export var preview: SpriteDisplay

var editor: SpriteEditor
var session: Session
var object: BinObject
var block: BinSpriteBlock

var files: PackedStringArray

var placement_method: PlacementMethod
var placement_manual_range: bool
var placement_by_filename: bool
var placement_position: int
var placement_from: int
var placement_to: int

var palette_embed: bool
var palette_half_size: bool
var palette_half_alpha: bool
var palette_reindex

var sprite_flip_h: bool
var sprite_flip_v: bool
var sprite_as_rgb: bool
var sprite_reindex: bool
var sprite_bit_depth: BitDepthMode

var imported_sprites: BinSpriteBlock = BinSpriteBlock.new()
var processed_sprites: Array[BinSprite] = []
var task_count: int

var mutex: Mutex = Mutex.new()


func _enter_tree() -> void:
	GlobalSignals.sprite_importer_opened.connect(open)
	files_browser.files_selected.connect(set_files)
	sprite_imported.connect(on_sprite_imported)
	sprite_processed.connect(on_sprite_processed)
	sprite_placed.connect(on_sprite_placed)
	all_sprites_processed.connect(place_sprites)
	
	visible = false
	preview.sprite_block = imported_sprites


func open(new_editor: SpriteEditor) -> void:
	editor = new_editor
	session = editor.session
	object = editor.object
	
	if object is BinScriptable:
		block = object.sprites
	elif object is BinSpriteBlock:
		block = object
	
	set_palette_override()
	session_set.emit(session, object)
	sprite_range_changed.emit(block)
	show()


func set_palette_override(index: int = 0) -> void:
	if has_palettes():
		var scriptable: BinScriptable = object
		preview.set_palette_override(scriptable.get_palette(index).palette)
	else:
		preview.set_palette_override()


func set_files(new_files: PackedStringArray) -> void:
	files = new_files
	
	task_count = new_files.size()
	imported_sprites.sprites.clear()
	imported_sprites.sprites.resize(task_count)
	processed_sprites.clear()
	GlobalSignals.progress_show("SPRITE_EDIT_IMPORT_PROGRESS_TITLE", task_count)
	WorkerThreadPool.add_group_task(
		thread_import.bind(new_files), task_count, -1, true
	)
	
	files_set.emit(new_files)


func has_palettes() -> bool:
	if object is BinScriptable:
		return object.has_palettes()
	
	return false


func get_palette_count() -> int:
	if has_palettes():
		return session.palettes.get_sprite_count()
	
	return 0


func set_placement_method(method: PlacementMethod) -> void:
	placement_method = method
	placement_method_set.emit(method)


func set_placement_manual_range(enabled: bool) -> void:
	placement_manual_range = enabled
	placement_manual_range_set.emit(enabled)


func set_placement_by_filename(enabled: bool) -> void:
	placement_by_filename = enabled
	placement_by_filename_set.emit(enabled)


func set_palette_enabled(enabled: bool) -> void:
	if has_palettes():
		preview.visible = true
		return
	
	palette_embed = enabled
	preview.visible = enabled
	palette_embed_set.emit(enabled)


func set_palette_half_size(enabled: bool) -> void:
	palette_half_size = enabled
	preview.set_half_clut(enabled)
	palette_half_size_set.emit(enabled)


func set_palette_half_alpha(enabled: bool) -> void:
	palette_half_alpha = enabled
	preview.set_alpha_double(!enabled)
	palette_half_alpha_set.emit(enabled)


func set_palette_reindex(enabled: bool) -> void:
	palette_reindex = enabled
	preview.set_reindex_palette(enabled)
	palette_reindex_set.emit(enabled)


func set_sprite_flip_h(enabled: bool) -> void:
	sprite_flip_h = enabled
	preview.flip_h = enabled
	sprite_flip_h_set.emit(enabled)


func set_sprite_flip_v(enabled: bool) -> void:
	sprite_flip_v = enabled
	preview.flip_v = enabled
	sprite_flip_v_set.emit(enabled)


func set_sprite_as_rgb(enabled: bool) -> void:
	sprite_as_rgb = enabled
	preview.set_as_rgb(enabled)
	sprite_as_rgb_set.emit(enabled)


func set_sprite_reindex(enabled: bool) -> void:
	sprite_reindex = enabled
	preview.set_reindex_pixels(enabled)
	sprite_reindex_set.emit(enabled)


func set_sprite_bit_depth(depth_mode: BitDepthMode) -> void: 
	sprite_bit_depth = depth_mode
	
	match depth_mode:
		BitDepthMode.SET_TO_4:
			preview.set_depth_4(true)
		BitDepthMode.SET_TO_8:
			preview.set_depth_8(true)
		_:
			preview.set_depth_4(false)
			preview.set_depth_8(false)
	
	sprite_bit_depth_set.emit(depth_mode)


func process_sprites() -> void:
	# Processing step
	task_count = files.size()
	GlobalSignals.progress_show("Processing sprites...", task_count)
	
	processed_sprites.clear()
	processed_sprites.resize(task_count)
	
	WorkerThreadPool.add_group_task(thread_process, task_count, -1, true)
	

func place_sprites() -> void:
	# Placement step
	task_count = files.size()
	WorkerThreadPool.add_task(thread_place)


func thread_import(index: int, file_list: PackedStringArray) -> void:
	imported_sprites.sprites[index] = BinSprite.load_from_file(
		file_list[index], true
	)
	sprite_imported.emit.call_deferred(WorkerThreadPool.get_caller_group_id())


func thread_process(i: int) -> void:
	var sprite: BinSprite = imported_sprites.sprites[i].duplicate()
	
	if sprite_flip_h && sprite_flip_v:
		sprite.flip_both()
	elif sprite_flip_h:
		sprite.flip_h()
	elif sprite_flip_v:
		sprite.flip_v()
	
	if sprite_as_rgb:
		sprite.convert_as_rgb()
	if sprite_reindex:
		sprite.reindex_pixels()
	match sprite_bit_depth:
		BitDepthMode.SET_TO_4:
			sprite.set_bit_depth_4()
		BitDepthMode.SET_TO_8:
			sprite.set_bit_depth_8()
	
	if not palette_embed:
		sprite.nuke_palette()
	
	else:
		if palette_reindex:
			sprite.reindex_palette()
		if palette_half_size:
			sprite.set_clut_half()
		if palette_half_alpha:
			sprite.palette_halve_alpha()
	
	processed_sprites[i] = sprite
	
	sprite_processed.emit.call_deferred(
		WorkerThreadPool.get_caller_group_id()
	)


func thread_place() -> void:
	var new_sprite_array: Array[BinSprite] = block.sprites.duplicate()
	
	match placement_method:
		PlacementMethod.APPEND:
			GlobalSignals.progress_show("Placing sprites...", 0)
			new_sprite_array.append_array(processed_sprites)
		
		PlacementMethod.INSERT:
			GlobalSignals.progress_show("Placing sprites...", 0)
			
			var l_side: Array[BinSprite] = new_sprite_array.slice(
				0, placement_position
			)
			
			l_side.append_array(processed_sprites)
			l_side.append_array(new_sprite_array.slice(
				placement_position, new_sprite_array.size()
			))
			new_sprite_array = l_side
			
		PlacementMethod.REPLACE:
			if placement_manual_range:
				task_count = placement_to - placement_from + 1
				var semaphore: Semaphore = Semaphore.new()
				
				GlobalSignals.progress_show("Placing sprites...", task_count)
				
				WorkerThreadPool.add_group_task(
					replace_manual.bind(
						semaphore, new_sprite_array, placement_from
					), task_count, -1, true
				)
				
				semaphore.wait()
			
			elif placement_by_filename:
				task_count = files.size()
				var semaphore: Semaphore = Semaphore.new()
				
				GlobalSignals.progress_show("Placing sprites...", task_count)
				
				WorkerThreadPool.add_group_task(
					replace_by_filename.bind(
						semaphore, new_sprite_array
					), task_count, -1, true
				)
				
				semaphore.wait()
				
			else:
				replace(new_sprite_array, placement_position)
	
	GlobalSignals.progress_finish()
	editor.set_sprite_array(new_sprite_array, processed_sprites.size())
	
	sprite_range_changed.emit.call_deferred(block)
	
	WorkerThreadPool.wait_for_task_completion.call_deferred(
		WorkerThreadPool.get_caller_task_id()
	)


func replace_manual(
	i: int, semaphore: Semaphore, into: Array[BinSprite], from: int
) -> void:
	var index: int = wrapi(from + i, 0, processed_sprites.size())
	var sprite: BinSprite = processed_sprites[index].duplicate(true)
	mutex.lock()
	into[from + i] = sprite
	mutex.unlock()
	GlobalSignals.progress_advance()
	
	sprite_placed.emit.call_deferred(
		WorkerThreadPool.get_caller_group_id(), semaphore
	)


func replace_by_filename(
	i: int, semaphore: Semaphore, into: Array[BinSprite]
) -> void:
	#GlobalSignals.progress_show("Placing sprites...", processed_sprites.size())
	var sprite: BinSprite = processed_sprites[i]
	var at: int = clampi(files[i].to_int(), 0, into.size() - 1)
	mutex.lock()
	into[at] = sprite
	mutex.unlock()
	GlobalSignals.progress_advance()
	
	sprite_placed.emit.call_deferred(
		WorkerThreadPool.get_caller_group_id(), semaphore
	)


func replace(into: Array[BinSprite], at: int) -> void:
	GlobalSignals.progress_show("Placing sprites...", processed_sprites.size())
	
	for i: int in processed_sprites.size():
		var sprite: BinSprite = processed_sprites[i]
		
		if i + at >= into.size():
			into.append(sprite)
		else:
			into[i + at] = sprite
		
		GlobalSignals.progress_advance()


func on_sprite_imported(group_id: int) -> void:
	GlobalSignals.progress_advance()
	task_count -= 1
	
	if task_count != 0:
		return
	
	task_count = -1
	WorkerThreadPool.wait_for_group_task_completion(group_id)
	
	if !imported_sprites.sprites.is_empty():
		preview.set_sprite(0)
	
	GlobalSignals.progress_finish()


func on_sprite_processed(group_id: int) -> void:
	GlobalSignals.progress_advance()
	task_count -= 1
	
	if task_count != 0:
		return
	
	task_count = -1
	WorkerThreadPool.wait_for_group_task_completion(group_id)
	all_sprites_processed.emit()
	

func on_sprite_placed(group_id: int, semaphore: Semaphore) -> void:
	task_count -= 1
	
	if task_count != 0:
		return

	task_count = -1
	WorkerThreadPool.wait_for_group_task_completion(group_id)
	processed_sprites.clear()
	GlobalSignals.progress_finish()
	semaphore.post()
