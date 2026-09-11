extends "res://SCENES/TABS/SHARED/basic_dialog.gd"

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

@export var range_from			: SteppingSpinBox
@export var range_to			: SteppingSpinBox

@export var action_sprites		: CheckButton
@export var action_palettes		: CheckButton
@export var action_flip_h		: CheckButton
@export var action_flip_v		: CheckButton
@export var action_bit_depth	: OptionButton
@export var action_clut_size	: OptionButton
@export var action_palette		: OptionButton

@export var apply_button		: Button
@export var preview				: SpriteDisplay
@export var progress_dialog		: Window

var from				: int = 0
var to					: int = 0
var reindex_pixels		: bool = false
var reindex_palettes	: bool = false
var flip_h				: bool = false
var flip_v				: bool = false
var depth_setting		: DepthSetting = DepthSetting.NO_CHANGE
var clut_setting		: CLUTSetting = CLUTSetting.NO_CHANGE
var palette				: PackedByteArray = []

var depth_memory		: PackedInt32Array
var clut_memory			: Dictionary[int, CLUTSetting]

var task_start			: int
var task_count			: int

@onready var editor				: SpriteEditor	= owner
@onready var undo_redo			: UndoRedo		= editor.undo_redo


func _ready() -> void:
	super._ready()
	
	range_from.value_changed.connect(set_from)
	range_to.value_changed.connect(set_to)
	
	action_sprites.toggled.connect(toggle_sprites)
		
	if not editor.object_has_palettes():
		action_palettes.toggled.connect(toggle_palettes)
	
	action_flip_h.toggled.connect(toggle_flip_h)
	action_flip_v.toggled.connect(toggle_flip_v)
	
	action_bit_depth.item_selected.connect(set_depth_mode)
	action_clut_size.item_selected.connect(set_clut_mode)
	
	apply_button.pressed.connect(apply_pressed)
	
	finished.connect(on_finished)


func set_from(new_value: int) -> void:
	from = new_value


func set_to(new_value: int) -> void:
	to = new_value


func toggle_sprites(toggled_on: bool) -> void:
	reindex_pixels = toggled_on
	preview.set_reindex(reindex_pixels != reindex_palettes)


func toggle_palettes(toggled_on: bool) -> void:
	reindex_palettes = toggled_on
	preview.set_reindex(reindex_pixels != reindex_palettes)


func toggle_flip_h(toggled_on: bool) -> void:
	flip_h = toggled_on
	preview.set_flip_h(flip_h)


func toggle_flip_v(toggled_on: bool) -> void:
	flip_v = toggled_on
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


func apply_pressed() -> void:
	if (
		!reindex_pixels && !reindex_palettes &&
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
		
	undo_redo.add_do_property(self, "depth_memory", new_depth_memory)
	undo_redo.add_do_property(self, "clut_memory", new_clut_memory)
	undo_redo.add_undo_property(self, "depth_memory", new_depth_memory)
	undo_redo.add_undo_property(self, "clut_memory", new_clut_memory)
	
	# Set up processes
	undo_redo.add_do_method(
		create_process_threads.bind(
			false,
			from, to,
			reindex_pixels, reindex_palettes,
			flip_h, flip_v,
			depth_setting, clut_setting,
		)
	)
	
	undo_redo.add_undo_method(
		create_process_threads.bind(
			true,
			from, to,
			reindex_pixels, reindex_palettes,
			flip_h, flip_v,
			depth_setting, clut_setting,
		)
	)
	
	undo_redo.commit_action()


func create_process_threads(
	p_undo: bool,
	p_from: int, p_to: int, p_pixels: bool, p_palettes: bool,
	p_flip_h: bool, p_flip_v: bool, p_depth: DepthSetting,
	p_clut_setting: CLUTSetting,
) -> void:
	progress_dialog.start.call_deferred(p_from, p_to)
	
	# Multithreading (min 1, max 4 threads)
	task_count = mini(p_to - p_from + 1, 4)
	task_start = Time.get_ticks_usec()
	
	for i: int in task_count:
		WorkerThreadPool.add_task(
			process.bind(
				task_count, i, p_undo,
				p_from, p_to,
				p_pixels, p_palettes,
				p_flip_h, p_flip_v,
				p_depth, p_clut_setting
			)
		)


func process(
	thread_count: int, thread_number: int, p_undo: bool, 
	p_from: int, p_to: int, p_pixels: bool, p_palettes: bool,
	p_flip_h: bool, p_flip_v: bool, p_depth: DepthSetting,
	p_clut: CLUTSetting,
) -> void:
	
	var sprite_block: BinSpriteBlock = editor.sprite_block
	
	var n_from: int = p_from
	var n_to: int = p_to
	
	while n_from % thread_count != thread_number:
		n_from += 1
	while n_to % thread_count != thread_number:
		n_to -= 1
	
	for i: int in range(n_from, n_to + 1, thread_count):
		var sprite: BinSprite = sprite_block.get_sprite(i)
		var depth: DepthSetting = DepthSetting.NO_CHANGE
		var clut: CLUTSetting = CLUTSetting.NO_CHANGE
		
		if i in depth_memory:
			depth = p_depth
			
			if p_undo:
				if depth == DepthSetting.SET_TO_4:
					depth = DepthSetting.SET_TO_8
				else:
					depth = DepthSetting.SET_TO_4
		
		if i in clut_memory:
			if p_undo:
				clut = clut_memory[i]
			else:
				clut = p_clut
		
		if clut == CLUTSetting.SET_TO_FULL:
			sprite.set_clut_full()
		
		if depth == DepthSetting.SET_TO_8:
			sprite.set_bit_depth_8()
			
		if p_pixels:
			sprite.reindex_pixels(false)
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
			sprite.flip_both(false)
		elif p_flip_h:
			sprite.flip_h(false)
		elif p_flip_v:
			sprite.flip_v(false)
		
		sprite.update_preview()
		progress_dialog.progress.call_deferred()
	
	var task_id: int = WorkerThreadPool.get_caller_task_id()
	finished.emit.call_deferred(task_id)


func on_finished(task_id: int) -> void:
	WorkerThreadPool.wait_for_task_completion(task_id)
	task_count -= 1
	
	if task_count == 0:
		editor.notify_info_outdated()
		editor.notify_preview_outdated()
		progress_dialog.finish.call_deferred()
