class_name SpriteEditor extends MarginContainer

signal sprite_changed
signal sprite_forced
signal preview_outdated
signal info_outdated

enum Mode {
	SPRITE_BLOCK,
	SCRIPTABLE,
}

var undo_redo: UndoRedo = UndoRedo.new()

var mode: Mode
var session: Session
var object: BinObject

var scriptable: BinScriptable
var sprite_block: BinSpriteBlock

var sprite_index: int = -1
var this_sprite: BinSprite

@export var pal_helper: PaletteEditorHelper
@export var pal_display: PaletteDisplay
@export var pal_selection: PaletteSelection


func _enter_tree() -> void:
	set_sprite(0)


func _ready() -> void:
	GlobalSignals.menu_undo.connect(undo)
	GlobalSignals.menu_redo.connect(redo)
	
	visibility_changed.connect(register_action_history)
	pal_helper.index_edited.connect(force_sprite)
	
	undo_redo.max_steps = Settings.misc_max_undo
	pal_helper.undo_redo = undo_redo
	
	register_action_history()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
	
	if Input.is_action_just_pressed("redo"):
		redo()
	
	elif Input.is_action_just_pressed("undo"):
		undo()


func initialize(p_session: Session, p_object: BinObject) -> void:
	session = p_session
	object = p_object
	
	if object is BinScriptable:
		mode = Mode.SCRIPTABLE
		scriptable = object
	else:
		mode = Mode.SPRITE_BLOCK
		sprite_block = object


func notify_info_outdated() -> void:
	info_outdated.emit()


func notify_preview_outdated() -> void:
	preview_outdated.emit()
 

#region Undo/Redo
func register_action_history() -> void:
	if !visible:
		return
	
	ActionHistory.set_undo_redo(undo_redo)


func status_register_action(action_text: String) -> void:
	undo_redo.add_do_method(Status.set_status.bind(action_text))
	undo_redo.add_undo_method(Status.set_status.bind(tr("ACTION_UNDO").format({
		"action": action_text
	})))


func undo() -> void:
	if not is_visible_in_tree():
		return
	
	if not undo_redo.has_undo():
		Status.set_status("ACTION_NO_UNDO")
		return
	
	undo_redo.undo()


func redo() -> void:
	if not is_visible_in_tree():
		return
	
	if not undo_redo.has_redo():
		Status.set_status("ACTION_NO_REDO")
		return
	
	undo_redo.redo()
#endregion


func get_sprite_count() -> int:
	return object.get_sprite_count()


func set_sprite(index: int) -> void:
	if index == sprite_index:
		return
	
	sprite_index = index
	this_sprite = object.get_sprite(index)
	
	pal_helper.set_sprite(this_sprite)
	pal_helper.edit_index = index
	
	notify_preview_outdated()
	notify_info_outdated()
	sprite_changed.emit()


func force_sprite(index: int) -> void:
	sprite_index = -1
	set_sprite(index)
	sprite_forced.emit(index)


func object_has_palettes() -> bool:
	return mode == Mode.SCRIPTABLE && scriptable.has_palettes()


func get_palette_count() -> int:
	if object_has_palettes():
		return scriptable.get_palette_count()
	else:
		return 0


func get_current_palette() -> PackedByteArray:
	if mode == Mode.SCRIPTABLE and scriptable.has_palettes():
		return scriptable.get_palette_array(session.palette_index)
	else:
		return this_sprite.palette
