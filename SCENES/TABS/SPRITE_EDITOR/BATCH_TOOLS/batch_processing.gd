
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


func apply_pressed() -> void:
	
	var action_text: String = "Batch process sprites #%s - #%s" % [from, to]
	
	undo_redo.create_action(action_text)
	editor.status_register_action(action_text)
	
	undo_redo.add_do_method(
		process_thread.bind(
			from, to, reindex_pixels, reindex_palettes, flip_h, flip_v
		)
	)
	undo_redo.add_undo_method(
		process_thread.bind(
			from, to, reindex_pixels, reindex_palettes, flip_h, flip_v
		)
	)
	
	undo_redo.commit_action()


func process_thread(
	p_from: int, p_to: int, p_pixels: bool, p_palettes: bool,
	p_flip_h: bool, p_flip_v: bool
) -> void:
	WorkerThreadPool.add_task(
		process.bind(p_from, p_to, p_pixels, p_palettes, p_flip_h, p_flip_v)
	)


func process(
	p_from: int, p_to: int, p_pixels: bool, p_palettes: bool,
	p_flip_h: bool, p_flip_v: bool
) -> void:
	progress_dialog.start.call_deferred(from, to)
	
	var sprite_block: BinSpriteBlock = editor.sprite_block

	for i: int in range(p_from, p_to + 1):
		var sprite: BinSprite = sprite_block.get_sprite(i)
		
		if p_pixels:
			sprite.reindex_pixels(false)
		if p_palettes:
			sprite.reindex_palette()
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
	progress_dialog.finish.call_deferred()


func on_finished(task_id: int) -> void:
	WorkerThreadPool.wait_for_task_completion(task_id)
	editor.notify_preview_outdated()


# I don't necessarily like this, but it's a pass-by-reference world out here.
func restore_pixels(sprite: BinSprite, pixels: PackedByteArray) -> void:
	sprite.pixels = pixels.duplicate()


func restore_palette(sprite: BinSprite, pal: PackedByteArray) -> void:
	sprite.palette = pal.duplicate()
