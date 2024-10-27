class_name SpriteEdit extends MarginContainer

signal sprite_updated

var undo_redo: UndoRedo = UndoRedo.new()

var obj_data: ObjectData

var sprite_index: int
var this_sprite: BinSprite

var palette_index: int
var this_palette: BinPalette

@export var sprite_index_spinbox: SpinBox

@export var info_dimensions: Label
@export var info_color_depth: Label
@export var info_embedded_pal: Label

var embedded_pal: bool = false

var provider: PaletteProvider


func _enter_tree() -> void:
	undo_redo.max_steps = Settings.misc_max_undo
	
	obj_data = SessionData.object_data_get(get_parent().name)
	
	provider = PaletteProvider.new()
	provider.undo_redo = undo_redo
	provider.obj_data = obj_data
	
	provider.palette_imported.connect(sprite_set)
	provider.sprite_reindexed.connect(sprite_reload)
	obj_data.palette_selected.connect(palette_set_no_broadcast)
	obj_data.palette_updated.connect(palette_load)


func _ready() -> void:
	provider.palette_load(0)
	sprite_set(0)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
	
	if Input.is_action_just_pressed("undo"):
		undo_redo.undo()
		if not obj_data.has_palettes():
			sprite_set(provider.sprite_index)
			sprite_index_spinbox.call_deferred(
				"set_value_no_signal", sprite_index)
	
	if Input.is_action_just_pressed("redo"):
		undo_redo.redo()
		if not obj_data.has_palettes():
			sprite_set(provider.sprite_index)
			sprite_index_spinbox.call_deferred(
				"set_value_no_signal", sprite_index)


func get_provider() -> PaletteProvider:
	return provider


func palette_set(index: int) -> void:
	palette_set_no_broadcast(index)
	obj_data.palette_broadcast(index)


func palette_set_no_broadcast(index: int) -> void:
	palette_index = index
	palette_load()


func palette_load() -> void:
	provider.palette_load(palette_index)


func palette_get(index: int) -> PackedByteArray:
	if obj_data.has_palettes():
		return obj_data.palette_get(index).palette
	else:
		return sprite_get(index).palette


#region Sprites
func sprite_get(index: int) -> BinSprite:
	return obj_data.sprite_get(index)


func sprite_get_count() -> int:
	return obj_data.sprites.size()


func sprite_set(index: int) -> void:
	sprite_index = index
	this_sprite = sprite_get(sprite_index)
	
	if obj_data.has_palettes():
		pass
	
	else:
		palette_index = sprite_index
		provider.palette_load(sprite_index)
	
	sprite_updated.emit(this_sprite)


func sprite_reload() -> void:
	sprite_set(sprite_index)


func sprite_delete(from: int, to: int) -> void:
	var how_many: int = to - from + 1
	
	var action_text: String = "Delete %s sprite(s)" % how_many
	undo_redo.create_action(action_text)
	
	# Shouldn't happen
	if how_many >= obj_data.sprites.size():
		Status.set_status("Can't delete all sprites!")
		return
	
	for index in how_many:
		undo_redo.add_do_method(sprite_delete_commit.bind(from))
		undo_redo.add_undo_method(sprite_insert_commit.bind(
			from, obj_data.sprites[from + how_many - index - 1]))
	
	var affected_cells: PackedInt64Array
	
	if SpriteImport.redirect_cells:
		affected_cells = obj_data.redirect_get_affected_cells(from)
		
		undo_redo.add_do_method(
			obj_data.redirect_sprite_indices.bind(from, how_many))
	
	else:
		affected_cells = obj_data.clamp_get_affected_cells(
			obj_data.sprites.size() - how_many)
	
		undo_redo.add_do_method(obj_data.clamp_sprite_indices)
	
	for cell in affected_cells:
		undo_redo.add_undo_property(
			obj_data.cells[cell].sprite_info, "index",
			obj_data.cells[cell].sprite_info.index)
	
	undo_redo.add_do_method(
		SpriteImport.emit_signal.bind("sprite_placement_finished"))
	undo_redo.add_undo_method(
		SpriteImport.emit_signal.bind("sprite_placement_finished"))
	
	undo_redo.commit_action()


func sprite_delete_commit(at: int) -> void:
	obj_data.sprites.pop_at(at)


func sprite_insert_commit(at: int, sprite: BinSprite) -> void:
	obj_data.sprites.insert(at, sprite)


func sprite_reindex() -> void:
	provider.sprite_reindex(this_sprite)
#endregion
