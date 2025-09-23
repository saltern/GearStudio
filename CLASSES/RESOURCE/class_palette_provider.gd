class_name PaletteProvider extends Resource

enum GradientMode {
	RGB,
	HSV,
	OKHSL,
}

signal palette_updated
@warning_ignore_start("unused_signal")
signal palette_imported		# Used by SpriteEdit
signal sprite_reindexed
signal sprite_select
@warning_ignore_restore("unused_signal")

var undo_redo: UndoRedo

var obj_data: Dictionary
var palette_index: int = 0
var palette: BinPalette
var sprite_index: int = 0
var sprite: BinSprite

var bit_depth: int
var color_index: int = 0

var by_channel: bool = false	# Set remotely by toggle CheckButton
var last_color: Color			# Set remotely by ColorPicker


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
		
		# A bit silly, but keeps external functionality/consistency
		var new_bin_pal: BinPalette = BinPalette.new()
		new_bin_pal.palette = sprite.palette
		palette = new_bin_pal
		
		palette_updated.emit(sprite.palette)


func palette_reload() -> void:
	if obj_data.has("palettes"):
		palette_load(palette_index)
	else:
		palette_load(sprite_index)


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
	var channels: Array[bool] = [true, true, true, true]
	
	if by_channel:
		if color.r == last_color.r:
			channels[0] = false
		if color.g == last_color.g:
			channels[1] = false
		if color.b == last_color.b:
			channels[2] = false
		if color.a == last_color.a:
			channels[3] = false
	
	var selected_count: int = 0
	
	for selected in selection:
		selected_count += selected as int
	
	if selected_count < 1:
		Status.set_status("STATUS_PROVIDER_NOTHING_SELECTED")
		return
	
	if obj_data.has("palettes"):
		palette_set_color_palette(color, selection, channels)
	else:
		palette_set_color_sprite(color, selection, channels)
	
	last_color = color


func palette_set_color_palette(
	color: Color, selection: Array[bool], channels: Array[bool]
) -> void:
	var action_text: String = tr("ACTION_PROVIDER_PALETTE_SET_COLOR").format({
		"index": palette_index
	})
	
	undo_redo.create_action(action_text)
	
	# Ensure palette selected before making changes
	undo_redo.add_do_method(palette_load.bind(palette_index))
	undo_redo.add_undo_method(palette_load.bind(palette_index))
	
	for index in 256:
		if not selection[index]:
			continue
		
		undo_redo.add_do_method(
			palette_set_color_commit.bind(index, color, channels))
		undo_redo.add_undo_method(
			palette_set_color_commit.bind(
				index, palette_get_color(index), channels)
		)
	
	# palette_updated signal needs to happen before palette_load call
	undo_redo.add_do_method(SessionData.set_palette.bind(palette_index))
	undo_redo.add_do_method(palette_load.bind(palette_index))
	
	undo_redo.add_undo_method(SessionData.set_palette.bind(palette_index))
	undo_redo.add_undo_method(palette_load.bind(palette_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func palette_set_color_sprite(
	color: Color, selection: Array[bool], channels: Array[bool]
) -> void:
	var action_text: String = tr("ACTION_PROVIDER_SPRITE_SET_COLOR").format({
		"index": sprite_index
	})
	
	undo_redo.create_action(action_text)
	
	# Ensure sprite selected before making changes
	undo_redo.add_do_method(emit_signal.bind("sprite_select", sprite_index))
	undo_redo.add_undo_method(emit_signal.bind("sprite_select", sprite_index))
	
	for index in pow(2, sprite.bit_depth): # 16 or 256
		if not selection[index]:
			continue
		
		undo_redo.add_do_method(
			sprite_set_color_commit.bind(index, color, channels))
		undo_redo.add_undo_method(
			sprite_set_color_commit.bind(
				index, palette_get_color(index), channels)
		)
	
	# palette_updated signal needs to happen before palette_load call
	undo_redo.add_do_method(
		SessionData.set_sprite_palette.bind(obj_data, sprite_index))
	undo_redo.add_do_method(palette_load.bind(sprite_index))

	undo_redo.add_undo_method(
		SessionData.set_sprite_palette.bind(obj_data, sprite_index))
	undo_redo.add_undo_method(palette_load.bind(sprite_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func palette_set_color_commit(
	index: int, color: Color, channels: Array[bool]
) -> void:
	if channels[0]:
		palette.palette[4 * index + 0] = color.r8
	if channels[1]:
		palette.palette[4 * index + 1] = color.g8
	if channels[2]:
		palette.palette[4 * index + 2] = color.b8
	if channels[3]:
		palette.palette[4 * index + 3] = color.a8


func sprite_set_color_commit(
	index: int, color: Color, channels: Array[bool]
) -> void:
	if channels[0]:
		sprite.palette[4 * index + 0] = color.r8
	if channels[1]:
		sprite.palette[4 * index + 1] = color.g8
	if channels[2]:
		sprite.palette[4 * index + 2] = color.b8
	if channels[3]:
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


func palette_apply_gradient(mode: GradientMode, selection: Array[bool]) -> void:
	var start_index: int = -1
	var end_index: int = -1
	var gradient_steps: int = 0
	
	# Get first color
	for index in selection.size():
		if selection[index]:
			start_index = index
			break
	
	if start_index == -1:
		Status.set_status("PROVIDER_GRADIENT_NOTHING_SELECTED")
		return
	
	# Get last color
	for index in selection.size():
		if selection[selection.size() - 1 - index]:
			end_index = selection.size() - 1 - index
			break
	
	if (end_index - start_index) < 2:
		Status.set_status("PROVIDER_GRADIENT_INSUFFICIENT_COLORS")
		return
	
	# Indices to apply to
	var apply_indices: PackedInt32Array = []
	
	# Get color count
	for index in selection.size():
		if selection[index]:
			gradient_steps += 1
			apply_indices.append(index)
	
	if Settings.pal_gradient_reindex:
		var reindex: Dictionary = {}
		
		for index in apply_indices:
			var reindexed: int = index
			
			if ((index / 8) + 2) % 4 == 0:
				reindexed -= 8
			elif ((index / 8) + 3) % 4 == 0:
				reindexed += 8
			
			reindex[reindexed] = index
		
		var keys: Array = reindex.keys()
		keys.sort()
		
		for key in keys.size():
			apply_indices[key] = reindex[keys[key]]
		
		start_index = apply_indices[0]
		end_index = apply_indices[-1]
	
	var start_color: Color = Color8(
		palette.palette[4 * start_index + 0],
		palette.palette[4 * start_index + 1],
		palette.palette[4 * start_index + 2],
		palette.palette[4 * start_index + 3],
	)
	
	var end_color: Color = Color8(
		palette.palette[4 * end_index + 0],
		palette.palette[4 * end_index + 1],
		palette.palette[4 * end_index + 2],
		palette.palette[4 * end_index + 3],
	)
	
	# Generate gradient
	var gradient: Array[Color] = palette_generate_gradient(
		mode, gradient_steps, start_color, end_color)
	
	var action_text: String = tr("ACTION_PROVIDER_MAKE_GRADIENT").format({
		"index": palette_index
	})
	
	var channels: Array[bool] = [true, true, true, true]
	
	undo_redo.create_action(action_text)
	
	var index: int = 0
	
	for color in gradient:
		undo_redo.add_do_method(palette_set_color_commit.bind(
			apply_indices[index], color, channels)
		)
		undo_redo.add_undo_method(palette_set_color_commit.bind(
			apply_indices[index], palette_get_color(apply_indices[index]), channels)
		)
		
		index += 1
	
	# palette_updated signal needs to happen before palette_load call
	undo_redo.add_do_method(SessionData.set_palette.bind(palette_index))
	undo_redo.add_do_method(palette_load.bind(palette_index))
	
	undo_redo.add_undo_method(SessionData.set_palette.bind(palette_index))
	undo_redo.add_undo_method(palette_load.bind(palette_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func palette_generate_gradient(
	mode: GradientMode, steps: int, start: Color, end: Color
) -> Array[Color]:
	var color_array: Array[Color] = []
	var f_steps: float = float(steps)
	
	color_array.append(start)
	
	for step in range(1.0, f_steps - 1):
		var progress: float = (1.0 / (f_steps - 1)) * (step)
		var new: Color = start
		
		match mode:
			GradientMode.RGB:
				new.r8 = lerp(start.r8, end.r8, progress)
				new.g8 = lerp(start.g8, end.g8, progress)
				new.b8 = lerp(start.b8, end.b8, progress)
			
			GradientMode.HSV:
				new.h = lerp(start.h, end.h, progress)
				new.s = lerp(start.s, end.s, progress)
				new.v = lerp(start.v, end.v, progress)
			
			GradientMode.OKHSL:
				new.ok_hsl_h = lerp(start.ok_hsl_h, end.ok_hsl_h, progress)
				new.ok_hsl_s = lerp(start.ok_hsl_s, end.ok_hsl_s, progress)
				new.ok_hsl_l = lerp(start.ok_hsl_l, end.ok_hsl_l, progress)
		
		color_array.append(new)
	
	return color_array
#endregion
