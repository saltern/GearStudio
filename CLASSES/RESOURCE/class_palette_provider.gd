class_name PaletteProvider extends Resource
 
signal palette_updated
@warning_ignore("unused_signal")
signal palette_imported		# Used by SpriteEdit
@warning_ignore("unused_signal")
signal sprite_reindexed

var undo_redo: UndoRedo

var obj_data: Dictionary
var palette_index: int = 0
var palette: BinPalette
var sprite_index: int = 0
var sprite: BinSprite

var bit_depth: int
var color_index: int = 0

var by_channel: bool = false

var last_color: Color


# Undo/Redo status shorthand
func status_register_action(action_text: String) -> void:
	undo_redo.add_do_method(Status.set_status.bind(action_text))
	undo_redo.add_undo_method(Status.set_status.bind(tr("ACTION_UNDO").format({
		"action": action_text
	})))


#region Copy/Paste
func set_copy_data(selection: Array[bool]) -> void:
	var copy_data: Array[Color] = []
	
	for index in 256:
		if not selection[index]:
			continue
		
		copy_data.append(palette_get_color(index))
	
	Clipboard.pal_selection = selection.duplicate()
	Clipboard.pal_data = copy_data


func paste(at: int, selection: Array[bool]) -> void:
	var selected_count: int = 0
	
	for selected in selection:
		selected_count += selected as int
	
	if Clipboard.pal_data.size() < 1:
		return
	
	if selected_count > 0:
		palette_paste_color_into(selection)
	else:
		palette_paste_color(at)
#endregion


#region Palettes
func palette_load(index: int = 0) -> void:
	if obj_data.has("palettes"):
		palette_index = index
		palette = obj_data["palettes"][palette_index]
		bit_depth = 8
		palette_updated.emit(palette.palette)
	
	else:
		sprite_index = index
		sprite = obj_data["sprites"][sprite_index]
		bit_depth = sprite.bit_depth
		palette_updated.emit(sprite.palette)


func palette_reload() -> void:
	palette_load(palette_index)


func palette_get_color_count() -> int:
	return palette_get_colors().size() / 4


func palette_get_colors() -> PackedByteArray:
	if obj_data.has("palettes"):
		return obj_data["palettes"][palette_index].palette
	else:
		return obj_data["sprites"][sprite_index].palette


func palette_get_color(index: int = 0) -> Color:
	if obj_data.has("palettes"):
		return Color8(
			palette.palette[4 * index + 0],
			palette.palette[4 * index + 1],
			palette.palette[4 * index + 2],
			palette.palette[4 * index + 3])
			
	else:
		if 4 * index >= sprite.palette.size():
			return Color8(0, 0, 0, 255)
		
		return Color8(
			sprite.palette[4 * index + 0],
			sprite.palette[4 * index + 1],
			sprite.palette[4 * index + 2],
			sprite.palette[4 * index + 3])


func palette_get_color_in(color: int = 0, index: int = 0) -> Color:
	if obj_data.has("palettes"):
		var pal: PackedByteArray = obj_data["palettes"][index].palette
		return Color8(
			pal[4 * color + 0],
			pal[4 * color + 1],
			pal[4 * color + 2],
			pal[4 * color + 3],
		)
		
	else:
		var pal: PackedByteArray = obj_data["sprites"][index].palette
		return Color8(
			pal[4 * color + 0],
			pal[4 * color + 1],
			pal[4 * color + 2],
			pal[4 * color + 3],
		)


func palette_set_color(color: Color, selection: Array[bool]) -> void:
	var selected_count: int = 0
	
	for selected in selection:
		selected_count += selected as int
	
	if selected_count < 1:
		Status.set_status("STATUS_PROVIDER_NOTHING_SELECTED")
		return
	
	if obj_data.has("palettes"):
		palette_set_color_palette(color, selection)
	else:
		palette_set_color_sprite(color, selection)


func palette_set_color_palette(color: Color, selection: Array[bool]) -> void:
	var action_text: String = tr("ACTION_PROVIDER_PALETTE_SET_COLOR").format({
		"index": palette_index
	})
	
	undo_redo.create_action(action_text)
	
	for index in 256:
		if not selection[index]:
			continue
		
		undo_redo.add_do_method(palette_set_color_commit.bind(index, color))
		undo_redo.add_undo_method(
			palette_set_color_commit.bind(index, palette_get_color(index))
		)
	
	# palette_updated signal needs to happen before palette_load call
	undo_redo.add_do_method(SessionData.set_palette.bind(palette_index))
	undo_redo.add_do_method(palette_load.bind(palette_index))
	
	undo_redo.add_undo_method(SessionData.set_palette.bind(palette_index))
	undo_redo.add_undo_method(palette_load.bind(palette_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func palette_set_color_sprite(color: Color, selection: Array[bool]) -> void:
	var action_text: String = tr("ACTION_PROVIDER_SPRITE_SET_COLOR").format({
		"index": sprite_index
	})
	
	undo_redo.create_action(action_text)
		
	for index in pow(2, sprite.bit_depth): # 16 or 256
		if not selection[index]:
			continue
		
		undo_redo.add_do_method(sprite_set_color_commit.bind(index, color))
		undo_redo.add_undo_method(
			sprite_set_color_commit.bind(index, palette_get_color(index))
		)
	
	# palette_updated signal needs to happen before palette_load call
	undo_redo.add_do_method(SessionData.set_palette.bind(sprite_index))
	undo_redo.add_do_method(palette_load.bind(sprite_index))

	undo_redo.add_undo_method(SessionData.set_palette.bind(sprite_index))
	undo_redo.add_undo_method(palette_load.bind(sprite_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func palette_set_color_commit(index: int, color: Color) -> void:
	palette.palette[4 * index + 0] = color.r8
	palette.palette[4 * index + 1] = color.g8
	palette.palette[4 * index + 2] = color.b8
	palette.palette[4 * index + 3] = color.a8


func sprite_set_color_commit(index: int, color: Color) -> void:
	sprite.palette[4 * index + 0] = color.r8
	sprite.palette[4 * index + 1] = color.g8
	sprite.palette[4 * index + 2] = color.b8
	sprite.palette[4 * index + 3] = color.a8


func palette_paste_color(at_index: int) -> void:
	var colors: int = palette_get_color_count()
	
	var old_palette: PackedByteArray
	var new_palette: PackedByteArray
	
	if obj_data.has("palettes"):
		old_palette = palette.palette.duplicate()
		new_palette = palette.palette.duplicate()
	
	else:
		old_palette = sprite.palette.duplicate()
		new_palette = sprite.palette.duplicate()
		
	var start_index: int = 0
	var current_color: int = 0
	
	for cell in colors:
		if Clipboard.pal_selection[cell]:
			start_index = cell
			break
	
	if at_index < 0 || at_index > colors - 1:
		return
	
	for cell in colors:
		var this_index: int = at_index - start_index + cell
		
		if !Clipboard.pal_selection[cell]:
			continue
		
		if this_index < 0 || this_index > colors - 1:
			continue
		
		new_palette[4 * this_index + 0] = Clipboard.pal_data[current_color].r8
		new_palette[4 * this_index + 1] = Clipboard.pal_data[current_color].g8
		new_palette[4 * this_index + 2] = Clipboard.pal_data[current_color].b8
		new_palette[4 * this_index + 3] = Clipboard.pal_data[current_color].a8
		
		current_color += 1
	
	palette_paste_color_commit(old_palette, new_palette)


func palette_paste_color_into(selection: Array[bool]) -> void:
	var current_color: int = 0
	
	var old_palette: PackedByteArray
	var new_palette: PackedByteArray
	
	if obj_data.has("palettes"):
		old_palette = palette.palette.duplicate()
		new_palette = palette.palette.duplicate()
	
	else:
		old_palette = sprite.palette.duplicate()
		new_palette = sprite.palette.duplicate()
	
	for cell in 256:
		if !selection[cell]:
			continue
		
		new_palette[4 * cell + 0] = Clipboard.pal_data[current_color].r8
		new_palette[4 * cell + 1] = Clipboard.pal_data[current_color].g8
		new_palette[4 * cell + 2] = Clipboard.pal_data[current_color].b8
		new_palette[4 * cell + 3] = Clipboard.pal_data[current_color].a8
		
		current_color = wrapi(current_color + 1, 0, Clipboard.pal_data.size())
	
	palette_paste_color_commit(old_palette, new_palette)
	

func palette_paste_color_commit(
	old: PackedByteArray, new: PackedByteArray
) -> void:
	var action_text: String
	
	if obj_data.has("palettes"):
		action_text = tr("ACTION_PROVIDER_PALETTE_PASTE_COLOR").format({
			"index": palette_index
		})
		undo_redo.create_action(action_text)
		
		undo_redo.add_do_property(palette, "palette", new)
		undo_redo.add_do_method(SessionData.set_palette.bind(palette_index))
		undo_redo.add_do_method(palette_load.bind(palette_index))
		
		undo_redo.add_undo_property(palette, "palette", old)
		undo_redo.add_do_method(SessionData.set_palette.bind(palette_index))
		undo_redo.add_undo_method(palette_load.bind(palette_index))
	
	else:
		action_text = tr("ACTION_PROVIDER_SPRITE_PASTE_COLOR").format({
			"index": sprite_index
		})
		undo_redo.create_action(action_text)
		
		undo_redo.add_do_property(sprite, "palette", new)
		undo_redo.add_do_method(obj_data.emit_signal.bind("palette_updated"))
		undo_redo.add_do_method(palette_load.bind(sprite_index))
		
		undo_redo.add_undo_property(sprite, "palette", old)
		undo_redo.add_undo_method(obj_data.emit_signal.bind("palette_updated"))
		undo_redo.add_undo_method(palette_load.bind(sprite_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func palette_import(pal_array: PackedByteArray) -> void:
	var action_text: String
	
	if obj_data.has("palettes"):
		# Ensure size of at least 256 colors.
		pal_array.resize(1024)
		
		action_text = tr("ACTION_PROVIDER_PALETTE_IMPORT").format({
			"index": palette_index
		})
		
		undo_redo.create_action(action_text)
		
		undo_redo.add_do_method(
			palette_import_commit.bind(palette, pal_array))
		undo_redo.add_do_method(palette_load.bind(palette_index))
		undo_redo.add_do_method(SessionData.set_palette.bind(palette_index))
		
		undo_redo.add_undo_method(
			palette_import_commit.bind(palette, palette.palette))
		undo_redo.add_undo_method(palette_load.bind(palette_index))
		undo_redo.add_undo_method(SessionData.set_palette.bind(palette_index))
	
	else:
		# Should normally not appear
		if sprite == null:
			Status.set_status("PROVIDER_CANNOT_IMPORT_NO_SPRITE")
			return
		
		# Adapt palette size to sprite bit depth
		pal_array.append_array(sprite.palette)
		pal_array.resize(4 * pow(2, sprite.bit_depth))
		
		action_text = tr("ACTION_PROVIDER_SPRITE_IMPORT").format({
			"index": sprite_index
		})
		
		undo_redo.create_action(action_text)
		
		undo_redo.add_do_method(
			palette_import_sprite_commit.bind(sprite, pal_array))
		undo_redo.add_do_method(palette_load.bind(sprite_index))
		undo_redo.add_do_method(SessionData.set_palette.bind(sprite_index))
		
		undo_redo.add_undo_method(
			palette_import_sprite_commit.bind(sprite, sprite.palette))
		undo_redo.add_undo_method(palette_load.bind(sprite_index))
		undo_redo.add_undo_method(SessionData.set_palette.bind(sprite_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func palette_import_sprite_commit(
	spr: BinSprite, pal_array: PackedByteArray
) -> void:
	spr.palette = pal_array


func palette_import_commit(
	pal: BinPalette, pal_array: PackedByteArray
) -> void:
	pal.palette = pal_array


func palette_reindex() -> void:
	if not obj_data.has("palettes"):
		return
	
	var action_text: String = tr("ACTION_PROVIDER_PALETTE_REINDEX").format({
		"index": palette_index
	})
	
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(palette.reindex)
	undo_redo.add_do_method(palette_load.bind(palette_index))
	undo_redo.add_do_method(SessionData.set_palette.bind(palette_index))
	
	undo_redo.add_undo_method(palette.reindex)
	undo_redo.add_undo_method(palette_load.bind(palette_index))
	undo_redo.add_undo_method(SessionData.set_palette.bind(palette_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()
#endregion
