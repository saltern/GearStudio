class_name PaletteEdit extends MarginContainer

@export var gradient_menu: PopupMenu

var session_id: int
var undo_redo: UndoRedo = UndoRedo.new()

var obj_data: Dictionary
var provider: PaletteProvider = PaletteProvider.new()


func _enter_tree() -> void:
	undo_redo.max_steps = Settings.misc_max_undo
	GlobalSignals.menu_undo.connect(undo)
	GlobalSignals.menu_redo.connect(redo)
	
	provider.undo_redo = undo_redo
	provider.obj_data = obj_data
	
	visibility_changed.connect(register_action_history)


func _ready() -> void:
	if not is_queued_for_deletion():
		provider.palette_load(0)


func _input(event: InputEvent) -> void:	
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
		
	if not event.pressed or event.echo:
		return
	
	if event.keycode == KEY_G:
		gradient_menu.display()
		return
	
	if Input.is_action_just_pressed("undo"):
		undo()
	
	if Input.is_action_just_pressed("redo"):
		redo()


func set_session_id(new_id: int) -> void:
	session_id = new_id


#region Undo/Redo
func register_action_history() -> void:
	if not is_visible_in_tree():
		return
	
	ActionHistory.set_undo_redo(undo_redo)


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


func get_provider() -> PaletteProvider:
	return provider


#region Sprites/Preview
func sprite_get_count() -> int:
	return obj_data["sprites"].size()


func sprite_get(index: int) -> BinSprite:
	return obj_data["sprites"][index]
#endregion


func palette_get_count() -> int:
	if obj_data.has("palettes"):
		return obj_data["palettes"].size()
	else:
		return 0


func palette_reindex() -> void:
	provider.palette_reindex()
