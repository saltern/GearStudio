class_name PaletteProvider extends Resource
 
signal palette_updated
signal palette_imported

var undo_redo: UndoRedo = UndoRedo.new()

var obj_data: ObjectData
var palette_index: int = 0
var palette: BinPalette
var sprite_index: int = 0
var sprite: BinSprite

var bit_depth: int
var color_count: int

var color_index: int = 0


func _init() -> void:
	undo_redo.max_steps = Settings.misc_max_undo


#region Undo/Redo
func undo() -> void:
	undo_redo.undo()


func redo() -> void:
	undo_redo.redo()
#endregion


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
	if obj_data.has_palettes():
		palette_index = index
		palette = obj_data.palette_get(palette_index)
		bit_depth = 8
		palette_updated.emit(palette.palette)
	
	else:
		sprite_index = index
		sprite = obj_data.sprite_get(sprite_index)
		bit_depth = sprite.bit_depth
		palette_updated.emit(sprite.palette)


func palette_get_color_count() -> int:
	return palette_get_colors().size() / 4


func palette_get_colors() -> PackedByteArray:
	if obj_data.has_palettes():
		return obj_data.palette_get(palette_index).palette
	else:
		return obj_data.sprites[sprite_index].palette


func palette_get_color(index: int = 0) -> Color:
	if obj_data.has_palettes():
		return Color8(
			palette.palette[4 * index + 0],
			palette.palette[4 * index + 1],
			palette.palette[4 * index + 2],
			palette.palette[4 * index + 3])
			
	else:
		return Color8(
			sprite.palette[4 * index + 0],
			sprite.palette[4 * index + 1],
			sprite.palette[4 * index + 2],
			sprite.palette[4 * index + 3])


func palette_get_color_in(color: int = 0, index: int = 0) -> Color:
	if obj_data.has_palettes():
		var pal: PackedByteArray = obj_data.palette_get(index).palette
		return Color8(
			pal[4 * color + 0],
			pal[4 * color + 1],
			pal[4 * color + 2],
			pal[4 * color + 3],
		)
		
	else:
		var pal: PackedByteArray = obj_data.sprites[index].palette
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
		Status.set_status("Nothing selected. Palette has not been modified.")
		return
	
	var old_palette: PackedByteArray
	var new_palette: PackedByteArray
	
	if obj_data.has_palettes():
		undo_redo.create_action("Sprite #%s set color(s)" % sprite_index)
		old_palette = palette.palette.duplicate()
		new_palette = palette.palette.duplicate()
	else:
		undo_redo.create_action("Palette #%s set color(s)" % palette_index)
		old_palette = sprite.palette.duplicate()
		new_palette = sprite.palette.duplicate()
	
	for index in 256:
		if not selection[index]:
			continue
		
		new_palette[4 * index + 0] = color.r8
		new_palette[4 * index + 1] = color.g8
		new_palette[4 * index + 2] = color.b8
		new_palette[4 * index + 3] = color.a8
	
	if obj_data.has_palettes():
		undo_redo.add_do_property(palette, "palette", new_palette)
		undo_redo.add_do_method(palette_load.bind(palette_index))
		
		undo_redo.add_undo_property(palette, "palette", old_palette)
		undo_redo.add_undo_method(palette_load.bind(palette_index))
	
	else:
		undo_redo.add_do_property(sprite, "palette", new_palette)
		undo_redo.add_do_method(palette_load.bind(sprite_index))
	
		undo_redo.add_undo_property(sprite, "palette", old_palette)
		undo_redo.add_undo_method(palette_load.bind(sprite_index))
	
	undo_redo.add_do_method(obj_data.emit_signal.bind("palette_updated"))
	undo_redo.add_undo_method(obj_data.emit_signal.bind("palette_updated"))
	
	undo_redo.commit_action()


func palette_paste_color(at_index: int) -> void:
	var color_count: int = palette_get_color_count()
	
	var old_palette: PackedByteArray
	var new_palette: PackedByteArray
	
	if obj_data.has_palettes():
		old_palette = palette.palette.duplicate()
		new_palette = palette.palette.duplicate()
	
	else:
		old_palette = sprite.palette.duplicate()
		new_palette = sprite.palette.duplicate()
		
	var start_index: int = 0
	var current_color: int = 0
	
	for cell in color_count:
		if Clipboard.pal_selection[cell]:
			start_index = cell
			break
	
	if at_index < 0 || at_index > color_count - 1:
		return
	
	for cell in color_count:
		var this_index: int = at_index - start_index + cell
		
		if !Clipboard.pal_selection[cell]:
			continue
		
		if this_index < 0 || this_index > color_count - 1:
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
	
	if obj_data.has_palettes():
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
	

func palette_paste_color_commit(old: PackedByteArray, new: PackedByteArray) -> void:
	if obj_data.has_palettes():
		undo_redo.create_action("Palette #%s paste color(s)" % palette_index)
		
		undo_redo.add_do_property(palette, "palette", new)
		undo_redo.add_do_method(palette_load.bind(palette_index))
		
		undo_redo.add_undo_property(palette, "palette", old)
		undo_redo.add_undo_method(palette_load.bind(palette_index))
	
	else:
		undo_redo.create_action("Sprite #%s paste color(s)" % sprite_index)
		
		undo_redo.add_do_property(sprite, "palette", new)
		undo_redo.add_do_method(palette_load.bind(sprite_index))
		
		undo_redo.add_undo_property(sprite, "palette", old)
		undo_redo.add_undo_method(palette_load.bind(sprite_index))
		
	undo_redo.commit_action()


func palette_import(pal_array: PackedByteArray) -> void:
	if obj_data.has_palettes():
		# Ensure size of at least 256 colors.
		pal_array.resize(1024)
		
		var action_text: String = "Set palette for index %s" % palette_index
		
		undo_redo.create_action(action_text)
		
		undo_redo.add_do_method(
			palette_import_commit.bind(palette, pal_array))
		undo_redo.add_do_method(palette_load.bind(palette_index))
		undo_redo.add_do_method(
			emit_signal.bind("palette_imported", palette_index))
		
		undo_redo.add_do_method(Status.set_status.bind("%s." % action_text))
		
		undo_redo.add_undo_method(
			palette_import_commit.bind(palette, palette.palette))
		undo_redo.add_undo_method(palette_load.bind(palette_index))
		undo_redo.add_undo_method(
			emit_signal.bind("palette_imported", palette_index))
		
		undo_redo.add_undo_method(
			Status.set_status.bind("Undo: %s." % action_text))
		
		undo_redo.commit_action()
	
	else:
		# Should normally not appear
		if sprite == null:
			Status.set_status("Could not apply palette, no sprite selected.")
			return
		
		# Adapt palette size to sprite bit depth
		pal_array.append_array(sprite.palette)
		pal_array.resize(4 * pow(2, sprite.bit_depth))
		
		var action_text: String = "Set palette for sprite %s" % sprite_index
		
		undo_redo.create_action(action_text)
		
		undo_redo.add_do_method(
			palette_import_sprite_commit.bind(sprite, pal_array))
		undo_redo.add_do_method(palette_load.bind(sprite_index))
		undo_redo.add_do_method(
			emit_signal.bind("palette_imported", sprite_index))
		
		undo_redo.add_do_method(Status.set_status.bind("%s." % action_text))
		
		undo_redo.add_undo_method(
			palette_import_sprite_commit.bind(sprite, sprite.palette))
		undo_redo.add_undo_method(palette_load.bind(sprite_index))
		undo_redo.add_undo_method(
			emit_signal.bind("palette_imported", sprite_index))
		
		undo_redo.add_undo_method(
			Status.set_status.bind("Undo: %s" % action_text))
		
		undo_redo.commit_action()


func palette_import_sprite_commit(
	spr: BinSprite, pal_array: PackedByteArray
) -> void:
	spr.palette = pal_array


func palette_import_commit(
	pal: BinPalette, pal_array: PackedByteArray
) -> void:
	pal.palette = pal_array
#endregion
