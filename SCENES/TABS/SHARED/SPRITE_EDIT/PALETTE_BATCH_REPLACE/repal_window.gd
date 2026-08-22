extends Window

signal palette_changed

enum SourceMode {
	SELF,
	FILE,
}

@export var summon_button: Button
@export var dialog_confirm: ConfirmationDialog
@export var dialog_progress: Window
@export var text_progress: Label

# Controls
# Source
@export_group("Source", "source_")
@export var source_self_button: CheckBox
@export var source_self_object: OptionButton
@export var source_self_sprite: SteppingSpinBox
@export var source_self_palette: SteppingSpinBox
@export var source_file_dialog: FileDialog

@export_group("Range", "range_")
@export var range_start: SteppingSpinBox
@export var range_end: SteppingSpinBox

@export_group("Misc", "misc_")
@export var misc_reindex: CheckButton

var source_mode: SourceMode = SourceMode.SELF
var source_object: BinObject

var self_palette: BinSprite
var file_palette: BinSprite
var palette: BinSprite
var reindex: bool

@onready var sprite_edit: SpriteEdit = owner


func _ready() -> void:
	summon_button.pressed.connect(show)
	close_requested.connect(hide)
	dialog_confirm.confirmed.connect(on_repal_confirmed)
	
	source_self_button.toggled.connect(toggle_source_self)
	source_self_object.item_selected.connect(on_object_selected.unbind(1))
	source_self_sprite.value_changed.connect(on_source_sprite_set)
	source_self_palette.value_changed.connect(on_source_palette_set)
	source_file_dialog.file_selected.connect(on_source_file_selected)
	
	misc_reindex.toggled.connect(on_reindex_toggled)
	
	file_palette = BinSprite.init_empty_palette()
	
	on_object_selected()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not event is InputEventKey:
		return
	if not event.pressed:
		return
	if event.is_echo():
		return
	
	if event.keycode == KEY_ESCAPE:
		hide()


func set_new_palette(colors: PackedByteArray) -> void:
	var new_palette: BinSprite = BinSprite.init_empty_palette()
	new_palette.palette = colors
	
	if reindex:
		new_palette.reindex()
	
	match source_mode:
		SourceMode.SELF:
			self_palette = new_palette
		SourceMode.FILE:
			file_palette = new_palette
	
	palette = new_palette
	palette_changed.emit()


func toggle_source_self(toggled_on: bool) -> void:
	if toggled_on:
		source_mode = SourceMode.SELF
		palette = self_palette
	else:
		source_mode = SourceMode.FILE
		palette = file_palette
	
	palette_changed.emit()


func on_object_selected() -> void:
	if not source_mode == SourceMode.SELF:
		return
	
	var object_id: int = source_self_object.get_selected_id()
	var session: Session = SessionData.get_current_session()
	source_object = session.archive.get_object(object_id)
	
	if source_object is BinScriptable:
		if source_object.has_palettes():
			var colors: PackedByteArray = source_object.get_palette_array(
				source_self_palette.value
			)
			set_new_palette(colors)

	else:
		var colors: PackedByteArray = source_object.get_palette_array(
			source_self_sprite.value
		)
		set_new_palette(colors)


func on_source_sprite_set(index: int) -> void:
	set_new_palette(source_object.sprites[index].palette)


func on_source_palette_set(index: int) -> void:
	set_new_palette(source_object.palettes[index].palette)


func on_source_file_selected(file: String) -> void:
	#var import_extension: String = file.get_extension().to_lower()
	
	var new_palette: BinSprite = BinSprite.load_from_file(file, true)
	
	set_new_palette(new_palette.palette)


func on_reindex_toggled(toggled_on: bool) -> void:
	reindex = toggled_on
	palette.reindex()
	palette_changed.emit()


func on_repal_confirmed() -> void:
	dialog_progress.show()
	var start: int = range_start.value
	var count: int = range_end.value - range_start.value + 1
	
	var undo_redo: UndoRedo = sprite_edit.undo_redo
	var action_text: String = tr("ACTION_SPRITE_EDIT_REPAL").format(
		{"count": count}
	)
	
	undo_redo.create_action(action_text)
	
	for i: int in count:
		text_progress.text = "%s / %s" % [i, count]
		
		var this_sprite: BinSprite = sprite_edit.obj_data.get_sprite(start + i)
		
		var old_palette: PackedByteArray = this_sprite.palette
		var new_palette: PackedByteArray = palette.palette.slice(
			0, (2 ** this_sprite.bit_depth) * 4
		)
		
		undo_redo.add_do_property(this_sprite, "palette", new_palette)
		undo_redo.add_undo_property(this_sprite, "palette", old_palette)
	
	undo_redo.add_do_method(sprite_edit.sprite_reload)
	undo_redo.add_undo_method(sprite_edit.sprite_reload)
	
	sprite_edit.status_register_action(action_text)
	undo_redo.commit_action()
	
	dialog_progress.hide()
