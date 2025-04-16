class_name SpriteEdit extends MarginContainer

signal sprite_updated

var session_id: int
var undo_redo: UndoRedo = UndoRedo.new()

var obj_data: Dictionary

var sprite_index: int
var this_sprite: BinSprite

var palette_index: int
var this_palette: BinPalette

@export var sprite_index_spinbox: SpinBox

@export var info_dimensions: Label
@export var info_color_depth: Label
@export var info_embedded_pal: Label

var embedded_pal: bool = false
var redirect_cells: bool = true

var provider: PaletteProvider


func _enter_tree() -> void:
	undo_redo.max_steps = Settings.misc_max_undo
	
	provider = PaletteProvider.new()
	provider.undo_redo = undo_redo
	provider.obj_data = obj_data
	
	provider.palette_imported.connect(sprite_set)
	provider.sprite_reindexed.connect(sprite_reload)
	
	if obj_data.has("palettes"):
		SessionData.palette_changed.connect(palette_set_session)


func _ready() -> void:
	provider.palette_load(0)
	sprite_set(0)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
	
	if Input.is_action_just_pressed("redo"):
		undo_redo.redo()
		
		if not obj_data.has("palettes"):
			sprite_set(provider.sprite_index)
			sprite_index_spinbox.call_deferred(
				"set_value_no_signal", sprite_index)
	
	elif Input.is_action_just_pressed("undo"):
		undo_redo.undo()
		
		if not obj_data.has("palettes"):
			sprite_set(provider.sprite_index)
			sprite_index_spinbox.call_deferred(
				"set_value_no_signal", sprite_index)


func set_session_id(new_id: int) -> void:
	session_id = new_id


# Undo/Redo status shorthand
func status_register_action(action_text: String) -> void:
	undo_redo.add_do_method(Status.set_status.bind(action_text))
	undo_redo.add_undo_method(Status.set_status.bind(tr("ACTION_UNDO").format({
		"action": action_text
	})))


func palette_set_session(for_session: int, index: int) -> void:
	if for_session != session_id:
		return
	
	palette_index = index
	palette_load()


func get_provider() -> PaletteProvider:
	return provider


func palette_load() -> void:
	provider.palette_load(palette_index)


func palette_get(index: int) -> PackedByteArray:
	if obj_data.has("palettes"):
		return obj_data["palettes"][index].palette
	else:
		return sprite_get(index).palette


#region Sprites
func sprite_get(index: int) -> BinSprite:
	return obj_data["sprites"][index]


func sprite_get_count() -> int:
	return obj_data["sprites"].size()


func sprite_set(index: int) -> void:
	index = min(index, sprite_get_count() - 1)
	
	sprite_index = index
	this_sprite = sprite_get(sprite_index)
	
	if obj_data.has("palettes"):
		pass
	
	else:
		palette_index = sprite_index
		provider.palette_load(sprite_index)
	
	sprite_updated.emit(this_sprite)


func sprite_get_texture(index: int) -> ImageTexture:
	return obj_data["sprites"][index].texture


func sprite_reload() -> void:
	sprite_set(sprite_index)


func sprite_delete(from: int, to: int) -> void:
	var how_many: int = to - from + 1
	
	var action_text: String = tr("ACTION_SPRITE_EDIT_DELETE").format({
		"count": how_many
	})
	undo_redo.create_action(action_text)
	
	# Shouldn't happen
	if how_many >= obj_data.sprites.size():
		Status.set_status("ACTION_SPRITE_EDIT_CANNOT_DELETE_ALL")
		return
	
	for index in how_many:
		undo_redo.add_do_method(sprite_delete_commit.bind(from))
		undo_redo.add_undo_method(sprite_insert_commit.bind(
			from, obj_data.sprites[from + how_many - index - 1]))
	
	var affected_cells: PackedInt64Array
	
	if redirect_cells:
		affected_cells = redirect_get_affected(from)
		undo_redo.add_do_method(redirect_sprite_indices.bind(from, how_many))
	
	else:
		affected_cells = clamp_get_affected(obj_data.sprites.size() - how_many)
		undo_redo.add_do_method(clamp_sprite_indices)
	
	for cell in affected_cells:
		undo_redo.add_undo_property(
			obj_data.cells[cell], "sprite_index",
			obj_data.cells[cell].sprite_index)
	
	undo_redo.add_do_method(
		SpriteImport.emit_signal.bind("sprite_placement_finished"))
	undo_redo.add_undo_method(
		SpriteImport.emit_signal.bind("sprite_placement_finished"))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func sprite_delete_commit(at: int) -> void:
	obj_data.sprites.pop_at(at)


func sprite_insert_commit(at: int, sprite: BinSprite) -> void:
	obj_data.sprites.insert(at, sprite)


func sprite_reindex() -> void:
	provider.sprite_reindex(this_sprite)
#endregion


#region Redirection/Clamping
# Clamp sprite index
func clamp_get_affected(sprite_max: int) -> PackedInt64Array:
	var return_array: PackedInt64Array = []
	
	for cell_number in obj_data.cells.size():
		if obj_data.cells[cell_number].sprite_index > sprite_max:
			return_array.append(cell_number)
	
	return return_array


func clamp_sprite_indices() -> void:
	var sprite_max: int = max(obj_data.sprites.size() - 1, 0)
	
	for cell in obj_data.cells:
		cell.clamp_sprite_index(sprite_max)


# Redirect sprite indices
func redirect_get_affected(from: int) -> PackedInt64Array:
	var return_array: PackedInt64Array = []
	
	if not obj_data.has("cells"):
		return return_array
	
	for cell_number in obj_data.cells.size():
		if obj_data.cells[cell_number].sprite_index > from:
			return_array.append(cell_number)
	
	return return_array


func redirect_sprite_indices(from: int, how_many: int) -> void:
	if not obj_data.has("cells"):
		return
	
	var to: int = from + how_many - 1
	
	for cell in obj_data.cells:
		if cell.sprite_index < from:
			continue
		
		elif cell.sprite_index <= to:
			cell.sprite_index = 0
		
		else:
			cell.sprite_index -= how_many
