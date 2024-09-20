class_name PaletteProvider extends Resource
 
var sprite_mode: bool = false

var undo_redo: UndoRedo = UndoRedo.new()

var pal_data: PaletteData
var palette_index: int = 0
var palette: BinPalette

var obj_data: ObjectData
var sprite_index: int = 0
var sprite: BinSprite

var bit_depth: int
var color_count: int

var color_index: int = 0

var colors_selected: Array[bool] = []
var color_selected_count: int = 0


func _init() -> void:
	undo_redo.max_steps = Settings.misc_max_undo
	colors_selected.resize(256)


#region Undo/Redo
func undo() -> void:
	undo_redo.undo()


func redo() -> void:
	undo_redo.redo()
#endregion


#region Selection
func color_select(index: int) -> void:
	colors_selected[index] = true


func color_deselect(index: int) -> void:
	colors_selected[index] = false


func color_deselect_all() -> void:
	colors_selected.resize(0)
	colors_selected.resize(256)


func color_set_selection(selecting: Array[bool], subtractive: bool) -> void:
	if subtractive:
		for index in 256:
			colors_selected[index] = \
				colors_selected[index] and not selecting[index]
			
	elif Input.is_key_pressed(KEY_SHIFT):
		for index in 256:
			colors_selected[index] = \
				colors_selected[index] or selecting[index]
	
	else:
		colors_selected = selecting.duplicate()
	
	color_selected_count = 0
	for cell in 256:
		color_selected_count += colors_selected[cell] as int
#endregion


#region Copy/Paste
func set_copy_data() -> void:
	var copy_data: Array[Color] = []
	
	for index in 256:
		if not colors_selected[index]:
			continue
		
		copy_data.append(palette_get_color(index))
	
	Clipboard.pal_selection = colors_selected.duplicate()
	Clipboard.pal_data = copy_data


func paste(at: int) -> void:
	if Clipboard.pal_data.size() < 1:
		return
	
	if color_selected_count > 0:
		palette_paste_color_into(colors_selected)
	else:
		palette_paste_color(at)
#endregion


#region BinPalettes
func palette_load(index: int = 0) -> void:
	if sprite_mode:
		sprite_index = index
		sprite = obj_data.sprites[sprite_index]
		
	else:
		palette_index = index
		palette = pal_data.palettes[palette_index]


func palette_get_colors(index: int = 0) -> PackedByteArray:
	if sprite_mode:
		return sprite.palette
	
	else:
		return pal_data.palettes[index].palette


func palette_get_color(index: int = 0) -> Color:
	if sprite_mode:
		return Color8(
			sprite.palette[4 * index + 0],
			sprite.palette[4 * index + 1],
			sprite.palette[4 * index + 2],
			sprite.palette[4 * index + 3])
	
	else:
		return Color8(
			palette.palette[4 * index + 0],
			palette.palette[4 * index + 1],
			palette.palette[4 * index + 2],
			palette.palette[4 * index + 3])


func palette_get_color_in(color: int = 0, index: int = 0) -> Color:
	if sprite_mode:
		return Color8(
			obj_data.sprites[index].palette[4 * color + 0],
			obj_data.sprites[index].palette[4 * color + 1],
			obj_data.sprites[index].palette[4 * color + 2],
			obj_data.sprites[index].palette[4 * color + 3],
		)
	
	else:
		return Color8(
			pal_data.palettes[index].palette[4 * color + 0],
			pal_data.palettes[index].palette[4 * color + 1],
			pal_data.palettes[index].palette[4 * color + 2],
			pal_data.palettes[index].palette[4 * color + 3])


func palette_set_color(color: Color) -> void:
	if color_selected_count < 1:
		Status.set_status("Nothing selected. Palette has not been modified.")
		return
	
	var old_palette: PackedByteArray
	var new_palette: PackedByteArray
	
	if sprite_mode:
		undo_redo.create_action("Palette #%s set color(s)" % palette_index)
		old_palette = sprite.palette.duplicate()
		new_palette = sprite.palette.duplicate()
	else:
		undo_redo.create_action("Sprite #%s set color(s)" % sprite_index)
		old_palette = palette.palette.duplicate()
		new_palette = palette.palette.duplicate()
	
	for index in 256:
		if not colors_selected[index]:
			continue
		
		new_palette[4 * index + 0] = color.r8
		new_palette[4 * index + 1] = color.g8
		new_palette[4 * index + 2] = color.b8
		new_palette[4 * index + 3] = color.a8
	
	if sprite_mode:
		undo_redo.add_do_property(sprite, "palette", new_palette)
		undo_redo.add_do_method(palette_load.bind(sprite_index))
	
		undo_redo.add_undo_property(sprite, "palette", old_palette)
		undo_redo.add_undo_method(palette_load.bind(sprite_index))
	
	else:
		undo_redo.add_do_property(palette, "palette", new_palette)
		undo_redo.add_do_method(palette_load.bind(palette_index))
		
		undo_redo.add_undo_property(palette, "palette", old_palette)
		undo_redo.add_undo_method(palette_load.bind(palette_index))
	
	undo_redo.commit_action()


func palette_paste_color(at_index: int) -> void:
	var old_palette: PackedByteArray
	var new_palette: PackedByteArray
	
	if sprite_mode:
		old_palette = sprite.palette.duplicate()
		new_palette = sprite.palette.duplicate()
		
	else:
		old_palette = palette.palette.duplicate()
		new_palette = palette.palette.duplicate()
	
	var start_index: int = 0
	var current_color: int = 0
	
	for cell in 256:
		if Clipboard.pal_selection[cell]:
			start_index = cell
			break
	
	if at_index < 0 || at_index > 255:
		return
	
	for cell in 256:
		var this_index: int = at_index - start_index + cell
		
		if !Clipboard.pal_selection[cell]:
			continue
		
		if this_index < 0 || this_index > 255:
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
	
	if sprite_mode:
		old_palette = sprite.palette.duplicate()
		new_palette = sprite.palette.duplicate()
	
	else:
		old_palette = palette.palette.duplicate()
		new_palette = palette.palette.duplicate()
	
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
	if sprite_mode:
		undo_redo.create_action("Sprite #%s paste color(s)" % sprite_index)
		
		undo_redo.add_do_property(sprite, "palette", new)
		undo_redo.add_do_method(palette_load.bind(sprite_index))
		
		undo_redo.add_undo_property(sprite, "palette", old)
		undo_redo.add_undo_method(palette_load.bind(sprite_index))
		
	else:
		undo_redo.create_action("Palette #%s paste color(s)" % palette_index)
		
		undo_redo.add_do_property(palette, "palette", new)
		undo_redo.add_do_method(palette_load.bind(palette_index))
		
		undo_redo.add_undo_property(palette, "palette", old)
		undo_redo.add_undo_method(palette_load.bind(palette_index))
	
	undo_redo.commit_action()
#endregion
