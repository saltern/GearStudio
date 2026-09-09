extends "res://SCENES/TABS/SHARED/basic_dialog.gd"

signal finished

@export var what_sprites: CheckButton
@export var what_palettes: CheckButton

@export var range_from: SteppingSpinBox
@export var range_to: SteppingSpinBox

@export var apply_button: Button

@export var preview: SpriteDisplay

@export var progress_dialog: Window

@onready var editor: SpriteEditor = owner
@onready var undo_redo: UndoRedo = editor.undo_redo

var reindex_sprites: bool = false
var reindex_palettes: bool = false


func _ready() -> void:
	super._ready()
	
	if editor.object_has_palettes():
		reindex_palettes = false
		toggle_sprites(true)
	else:
		what_sprites.toggled.connect(toggle_sprites)
		what_palettes.toggled.connect(toggle_palettes)
	
	apply_button.pressed.connect(apply_pressed)
	
	finished.connect(on_finished)


func toggle_sprites(toggled_on: bool) -> void:
	reindex_sprites = toggled_on
	preview.set_reindex(reindex_sprites != reindex_palettes)


func toggle_palettes(toggled_on: bool) -> void:
	reindex_palettes = toggled_on
	preview.set_reindex(reindex_sprites != reindex_palettes)


func apply_pressed() -> void:
	var from: int = range_from.value
	var to: int = range_to.value
	
	var action_text: String = "Batch reindex sprites #%s - #%s" % [from, to]
	
	undo_redo.create_action(action_text)
	editor.status_register_action(action_text)
	undo_redo.add_do_method(create_process_thread.bind(from, to))
	undo_redo.add_undo_method(create_process_thread.bind(from, to))
	undo_redo.commit_action()


func create_process_thread(from: int, to: int) -> void:
	WorkerThreadPool.add_task(process.bind(from, to))


func process(from: int, to: int) -> void:
	progress_dialog.start.call_deferred(from, to)
	
	var sprite_block: BinSpriteBlock = editor.sprite_block

	for i: int in range(from, to + 1):
		var sprite: BinSprite = sprite_block.get_sprite(i)
		
		if reindex_sprites:
			sprite.reindex_pixels()
		if reindex_palettes:
			sprite.reindex_palette()
		
		progress_dialog.progress.call_deferred()
	
	var task_id: int = WorkerThreadPool.get_caller_task_id()
	finished.emit.call_deferred(task_id)
	progress_dialog.finish.call_deferred()


func on_finished(task_id: int) -> void:
	WorkerThreadPool.wait_for_task_completion(task_id)
	editor.notify_preview_outdated()
