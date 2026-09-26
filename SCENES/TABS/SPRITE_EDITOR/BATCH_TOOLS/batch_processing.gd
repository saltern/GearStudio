class_name BatchProcessingTool extends BasicDialog

signal finished

enum DepthSetting {
	NO_CHANGE,
	SET_TO_4,
	SET_TO_8,
}

enum CLUTSetting {
	NO_CHANGE,
	REMOVE,
	SET_TO_HALF,
	SET_TO_FULL,
}

enum PaletteSetting {
	NO_CHANGE,
	FROM_CLIPBOARD,
	FROM_FILE,
}

@export var palette_preview		: PaletteDisplay
@export var preview				: SpriteDisplay

var from				: int = 0
var to					: int = 0
var reindex_pixels		: bool = false
var reindex_palette		: bool = false
var flip_h				: bool = false
var flip_v				: bool = false
var depth_setting		: DepthSetting = DepthSetting.NO_CHANGE
var clut_setting		: CLUTSetting = CLUTSetting.NO_CHANGE
var palette_setting		: PaletteSetting = PaletteSetting.NO_CHANGE
var palette				: PackedByteArray = []

var depth_memory		: PackedInt32Array
var clut_memory			: Dictionary[int, CLUTSetting]
var palette_memory		: Dictionary[int, PackedByteArray]

var task_start			: int
var task_count			: int

@onready var editor				: SpriteEditor	= owner
@onready var undo_redo			: UndoRedo		= editor.undo_redo


func _ready() -> void:
	super._ready()
	visibility_changed.connect(on_display)
	finished.connect(on_finished)


func set_from(new_value: int) -> void:
	from = new_value


func set_to(new_value: int) -> void:
	to = new_value


func set_reindex_pixels(enabled: bool) -> void:
	reindex_pixels = enabled
	preview.set_reindex_pixels(reindex_pixels)


func set_reindex_palettes(enabled: bool) -> void:
	reindex_palette = enabled
	preview.set_reindex_palette(reindex_palette)


func set_flip_h(enabled: bool) -> void:
	flip_h = enabled
	preview.set_flip_h(flip_h)


func set_flip_v(enabled: bool) -> void:
	flip_v = enabled
	preview.set_flip_v(flip_v)


func set_depth_mode(new_mode: DepthSetting) -> void:
	depth_setting = new_mode
	
	match depth_setting:
		DepthSetting.NO_CHANGE:
			preview.set_depth_4(false)
			preview.set_depth_8(false)
		DepthSetting.SET_TO_4:
			preview.set_depth_4(true)
		_:
			preview.set_depth_8(true)


func set_clut_mode(new_mode: CLUTSetting) -> void:
	clut_setting = new_mode
	
	preview.show()
	
	match clut_setting:
		CLUTSetting.REMOVE:
			preview.hide()
		CLUTSetting.SET_TO_HALF:
			preview.set_half_clut(true)
		CLUTSetting.SET_TO_FULL, CLUTSetting.NO_CHANGE:
			preview.set_half_clut(false)


func set_palette_mode(new_mode: PaletteSetting) -> void:
	palette_setting = new_mode
	
	match palette_setting:
		PaletteSetting.NO_CHANGE:
			preview.set_palette_override()
		PaletteSetting.FROM_CLIPBOARD:
			palette = Clipboard.pal_data
			update_palettes()
		#PaletteSetting.FROM_FILE:
			#palette_browser.show()


func import_palette(path: String) -> void:
	var sprite: BinSprite = BinSprite.load_from_file(path, true)
	
	if sprite == null:
		Status.set_status("Invalid file selected!")
		return
	
	if !sprite.has_palette():
		Status.set_status("Imported file contains no palette data!")
		return
	
	palette = sprite.palette
	update_palettes()


func update_palettes() -> void:
	palette_preview.set_palette(palette)
	preview.set_palette_override(palette)


func confirm_process() -> void:
	if (
		!reindex_pixels && !reindex_palette &&
		!flip_h && !flip_v &&
		depth_setting == DepthSetting.NO_CHANGE &&
		clut_setting == CLUTSetting.NO_CHANGE &&
		palette.is_empty()
	):
		Status.set_status("No processes were selected, so no action was taken.")
		return
	
	var action_text: String = "Batch process sprites #%s - #%s" % [from, to]
	
	undo_redo.create_action(action_text)
	editor.status_register_action(action_text)
	
	# Set up depth memory
	var new_depth_memory: PackedInt32Array = []
	var new_clut_memory: Dictionary[int, CLUTSetting] = {}
	var new_palette_memory: Dictionary[int, PackedByteArray] = {}
	
	for i: int in range(from, to + 1):
		var sprite: BinSprite = editor.get_sprite(i)
		
		match depth_setting:
			DepthSetting.SET_TO_4:
				if sprite.bit_depth == BinSprite.DEPTH_8:
					new_depth_memory.append(i)
			DepthSetting.SET_TO_8:
				if sprite.bit_depth == BinSprite.DEPTH_4:
					new_depth_memory.append(i)
		
		if clut_setting != CLUTSetting.NO_CHANGE:
			match sprite.clut:
				BinSprite.CLUT.NONE:
					if clut_setting != CLUTSetting.REMOVE:
						new_clut_memory[i] = CLUTSetting.REMOVE
				BinSprite.CLUT.HALF:
					if clut_setting != CLUTSetting.SET_TO_HALF:
						new_clut_memory[i] = CLUTSetting.SET_TO_HALF
				BinSprite.CLUT.FULL:
					if clut_setting != CLUTSetting.SET_TO_FULL:
						new_clut_memory[i] = CLUTSetting.SET_TO_FULL
		
		if palette_setting != PaletteSetting.NO_CHANGE:
			new_palette_memory[i] = sprite.palette
		
	undo_redo.add_do_property(self, "depth_memory", new_depth_memory)
	undo_redo.add_do_property(self, "clut_memory", new_clut_memory)
	undo_redo.add_do_property(self, "palette_memory", new_palette_memory)
	undo_redo.add_undo_property(self, "depth_memory", new_depth_memory)
	undo_redo.add_undo_property(self, "clut_memory", new_clut_memory)
	undo_redo.add_undo_property(self, "palette_memory", new_palette_memory)
	
	var p_palette: PackedByteArray = []
	
	if palette_setting != PaletteSetting.NO_CHANGE:
		p_palette = palette.duplicate()
	
	# Set up processes
	undo_redo.add_do_method(
		create_threads.bind(
			false,
			from, to,
			reindex_pixels, reindex_palette,
			flip_h, flip_v,
			depth_setting, clut_setting,
			p_palette,
		)
	)
	
	undo_redo.add_undo_method(
		create_threads.bind(
			true,
			from, to,
			reindex_pixels, reindex_palette,
			flip_h, flip_v,
			depth_setting, clut_setting,
			p_palette,
		)
	)
	
	undo_redo.commit_action()


func create_threads(
	p_undo: bool,
	p_from: int, p_to: int, p_pixels: bool, p_palettes: bool,
	p_flip_h: bool, p_flip_v: bool, p_depth: DepthSetting,
	p_clut_setting: CLUTSetting, p_palette: PackedByteArray,
) -> void:
	task_start = Time.get_ticks_msec()
	task_count = p_to - p_from + 1
	
	GlobalSignals.progress_show("Processing sprites...", task_count)
	
	WorkerThreadPool.add_group_task(
		thread_process.bind(
			p_from, p_undo,
			p_pixels, p_palettes,
			p_flip_h, p_flip_v,
			p_depth,
			p_clut_setting, p_palette
		), task_count, -1, true
	)


func thread_process(
	i: int, p_from: int,
	p_undo: bool, 
	p_pixels: bool, p_palettes: bool,
	p_flip_h: bool, p_flip_v: bool,
	p_depth: DepthSetting,
	p_clut: CLUTSetting, p_palette: PackedByteArray,
) -> void:
	var index: int = p_from + i
	var sprite: BinSprite = editor.sprite_block.get_sprite(index)
	
	var depth: DepthSetting = DepthSetting.NO_CHANGE
	var clut: CLUTSetting = CLUTSetting.NO_CHANGE
	
	if index in depth_memory:
		depth = p_depth
		
		if p_undo:
			if depth == DepthSetting.SET_TO_4:
				depth = DepthSetting.SET_TO_8
			else:
				depth = DepthSetting.SET_TO_4
	
	if index in clut_memory:
		if p_undo:
			clut = clut_memory[index]
		else:
			clut = p_clut
	
	if clut == CLUTSetting.SET_TO_FULL:
		sprite.set_clut_full()
	
	if depth == DepthSetting.SET_TO_8:
		sprite.set_bit_depth_8()
	
	if !p_palette.is_empty():
		if p_undo:
			sprite.palette = palette_memory[index].duplicate()
		else:
			sprite.palette = p_palette
	
	if p_pixels:
		sprite.reindex_pixels()
	if p_palettes:
		sprite.reindex_palette()
	
	if depth == DepthSetting.SET_TO_4:
		sprite.set_bit_depth_4()
	
	match clut:
		CLUTSetting.REMOVE:
			sprite.set_clut_none()
		CLUTSetting.SET_TO_HALF:
			sprite.set_clut_half()
	
	if p_flip_h && p_flip_v:
		sprite.flip_both()
	elif p_flip_h:
		sprite.flip_h()
	elif p_flip_v:
		sprite.flip_v()
	
	# Speed boost: do not update previews, just delete them
	# and let them be recreated on demand.
	sprite.clear_preview()
	finished.emit.call_deferred(WorkerThreadPool.get_caller_group_id())


func on_display() -> void:
	if !visible:
		return
	
	if palette_setting == PaletteSetting.FROM_CLIPBOARD:
		palette = Clipboard.pal_data
		update_palettes()


func on_finished(group_id: int) -> void:
	GlobalSignals.progress_advance()
	task_count -= 1
	
	if task_count != 0:
		return
	
	task_count = -1
	WorkerThreadPool.wait_for_group_task_completion(group_id)
	GlobalSignals.progress_finish()
	
	editor.notify_info_outdated()
	editor.notify_preview_outdated()
	editor.pal_helper.signal_sprite_updated()
