class_name PaletteEdit extends MarginContainer

signal palette_updated
signal color_selected

var undo: UndoRedo = UndoRedo.new()

var pal_data: PaletteData
var obj_data: ObjectData

var this_palette: BinPalette
var palette_index: int = 0
var color_index: int = 0

var colors_selected: Array[bool] = []
var color_selected_count: int = 0


func _enter_tree() -> void:
	undo.max_steps = Settings.misc_max_undo


func _ready() -> void:
	pal_data = SessionData.palette_data_get(
		get_parent().get_parent().get_index())
	
	obj_data = SessionData.object_data_get(
		get_parent().name)
	
	colors_selected.resize(256)


func _input(event: InputEvent) -> void:	
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
		
	if not event.pressed or event.echo:
		return
	
	if Input.is_action_just_pressed("undo"):
		undo.undo()
	
	elif Input.is_action_just_pressed("redo"):
		undo.redo()


#region Selection
func color_select(index: int) -> void:
	colors_selected[index] = true


func color_select_single(index: int) -> void:
	color_deselect_all()
	color_select(index)


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
		
	#color_selected.emit(colors_selected.rfind(true))
		
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


#region Sprites/Preview
func sprite_get_count() -> int:
	return obj_data.sprites.size()


func sprite_get(index: int) -> BinSprite:
	return obj_data.sprites[index]
#endregion


#region Palette data
func palette_load(number: int = 0) -> void:
	palette_index = number
	this_palette = pal_data.palettes[palette_index]
	palette_updated.emit(this_palette)


func palette_get_colors(index: int = 0) -> PackedByteArray:
	return pal_data.palettes[index].palette


func palette_get_color(index: int = 0) -> Color:
	return Color8(
		this_palette.palette[4 * index + 0],
		this_palette.palette[4 * index + 1],
		this_palette.palette[4 * index + 2],
		this_palette.palette[4 * index + 3])


func palette_get_color_in(index: int = 0, palette: int = 0) -> Color:
	return Color8(
		pal_data.palettes[palette].palette[4 * index + 0],
		pal_data.palettes[palette].palette[4 * index + 1],
		pal_data.palettes[palette].palette[4 * index + 2],
		pal_data.palettes[palette].palette[4 * index + 3])


func palette_set_color(color: Color) -> void:
	if color_selected_count < 1:
		Status.set_status("Nothing selected. Palette has not been modified.")
		return
	
	undo.create_action("Palette #%s set color(s)" % palette_index)
	
	var old_palette: PackedByteArray = this_palette.palette.duplicate()
	var new_palette: PackedByteArray = this_palette.palette.duplicate()
	
	for index in 256:
		if not colors_selected[index]:
			continue
		
		new_palette[4 * index + 0] = color.r8
		new_palette[4 * index + 1] = color.g8
		new_palette[4 * index + 2] = color.b8
		new_palette[4 * index + 3] = color.a8
	
	undo.add_do_property(this_palette, "palette", new_palette)
	undo.add_do_method(palette_load.bind(palette_index))
	
	undo.add_undo_property(this_palette, "palette", old_palette)
	undo.add_undo_method(palette_load.bind(palette_index))
	
	undo.commit_action()


func palette_paste_color(at_index: int) -> void:
	var old_palette: PackedByteArray = this_palette.palette.duplicate()
	var new_palette: PackedByteArray = this_palette.palette.duplicate()
	
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
	
	var old_palette: PackedByteArray = this_palette.palette.duplicate()
	var new_palette: PackedByteArray = this_palette.palette.duplicate()
	
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
	undo.create_action("Palette #%s paste color(s)" % palette_index)
	
	undo.add_do_property(this_palette, "palette", new)
	undo.add_do_method(palette_load.bind(palette_index))
	
	undo.add_undo_property(this_palette, "palette", old)
	undo.add_undo_method(palette_load.bind(palette_index))
	
	undo.commit_action()
#endregion
