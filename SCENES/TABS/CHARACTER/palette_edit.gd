class_name PaletteEdit extends MarginContainer

@export var gradient_menu: PopupMenu

var undo_redo: UndoRedo = UndoRedo.new()

var obj_data: ObjectData
var provider: PaletteProvider = PaletteProvider.new()


func _enter_tree() -> void:
	undo_redo.max_steps = Settings.misc_max_undo
	
	obj_data = SessionData.object_data_get(get_parent().name)
	
	if not obj_data.has_palettes():
		queue_free()
	
	provider.undo_redo = undo_redo
	provider.obj_data = obj_data


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
	
	if Input.is_action_just_pressed("redo"):
		undo_redo.redo()
	
	elif Input.is_action_just_pressed("undo"):
		undo_redo.undo()


func get_provider() -> PaletteProvider:
	return provider


#region Sprites/Preview
func sprite_get_count() -> int:
	return obj_data.sprite_get_count()


func sprite_get(index: int) -> BinSprite:
	return obj_data.sprite_get(index)
#endregion


func palette_get_count() -> int:
	return obj_data.palette_get_count()


func palette_reindex() -> void:
	provider.palette_reindex()
