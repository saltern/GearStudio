class_name PaletteEditorHelper extends Node

enum Context {
	SPRITE_EDITOR,
	PALETTE_EDITOR,
}

enum GradientMode {
	RGB,
	HSV,
	OKHSL,
}

enum Channel {
	RED,
	GREEN,
	BLUE,
	ALPHA,
}

signal sprite_updated
signal index_edited

var undo_redo: UndoRedo
var sprite: BinSprite
var edit_index: int

@export var context: Context
@export var selection: PaletteSelection

var by_channel: bool
var last_color: Color


func signal_index_edited(index: int) -> void:
	index_edited.emit(index)


func signal_sprite_updated() -> void:
	sprite_updated.emit()


func status_register_action(action_text: String) -> void:
	undo_redo.add_do_method(Status.set_status.bind(action_text))
	undo_redo.add_undo_method(Status.set_status.bind(tr("ACTION_UNDO").format({
		"action": action_text
	})))


func set_sprite(new_sprite: BinSprite) -> void:
	sprite = new_sprite
	sprite_updated.emit()


func get_palette() -> PackedByteArray:
	return sprite.palette


func get_color_count() -> int:
	return sprite.get_color_count()
	
	
func get_color(index: int) -> Color:
	return sprite.get_color(index)
	
	
func set_color(color: Color) -> void:
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
	
	for selected in selection.selected:
		selected_count += selected as int
	
	if selected_count < 1:
		Status.set_status("STATUS_PROVIDER_NOTHING_SELECTED")
		return
	
	var action_text: String = tr("ACTION_PROVIDER_PALETTE_SET_COLOR").format({
		"index": edit_index
	})
	
	undo_redo.create_action(action_text)
	
	# Broadcast signal to select correct sprite in editor
	undo_redo.add_do_method(signal_index_edited.bind(edit_index))
	undo_redo.add_undo_method(signal_index_edited.bind(edit_index))
	
	for index: int in get_color_count():
		if not selection.is_selected(index):
			continue
		
		undo_redo.add_do_method(
			set_color_commit.bind(sprite, index, color, channels)
		)
		undo_redo.add_undo_method(
			set_color_commit.bind(sprite, index, get_color(index), channels)
		)
	
	undo_redo.add_do_method(signal_sprite_updated)
	undo_redo.add_undo_method(signal_sprite_updated)
	
	status_register_action(action_text)
	undo_redo.commit_action()
	
	last_color = color


func set_color_commit(
	target: BinSprite, index: int, color: Color, channels: Array[bool]
) -> void:
	var from_color: Color = target.get_color(index)
	var to_color: Color = from_color
	
	if channels[Channel.RED]:
		to_color.r8 = color.r8
	if channels[Channel.GREEN]:
		to_color.g8 = color.g8
	if channels[Channel.BLUE]:
		to_color.b8 = color.b8
	if channels[Channel.ALPHA]:
		to_color.a8 = color.a8
	
	target.set_color(index, to_color.r8, to_color.g8, to_color.b8, to_color.a8)


func copy() -> void:
	var copy_data: PackedColorArray = []
	
	for index: int in get_color_count():
		if not selection.is_selected(index):
			continue
		
		copy_data.append(get_color(index))
	
	Clipboard.pal_selection = selection.selected.duplicate()
	Clipboard.pal_data = copy_data
	
	
func paste(at: int) -> void:
	var selected_count: int = 0
	
	for item: bool in selection.selected:
		selected_count += item as int
	
	if Clipboard.pal_data.size() < 1:
		return
	
	var action_text: String = tr("ACTION_PROVIDER_SPRITE_PASTE_COLOR").format({
		"index": edit_index
	})
	
	undo_redo.create_action(action_text)
	status_register_action(action_text)
	
	if selected_count == 0:
		paste_at(at)
	else:
		paste_into()


func paste_at(at: int) -> void:
	var new_palette: PackedByteArray = sprite.palette.duplicate()
		
	var start_index: int = 0
	var current_color: int = 0
	
	for cell in get_color_count():
		if Clipboard.pal_selection[cell]:
			start_index = cell
			break
	
	if at < 0 || at > get_color_count() - 1:
		return
	
	for index: int in get_color_count():
		var this_index: int = at - start_index + index
		
		if !Clipboard.pal_selection[index]:
			continue
		
		if this_index < 0 || this_index > get_color_count() - 1:
			continue
		
		new_palette[4 * this_index + 0] = Clipboard.pal_data[current_color].r8
		new_palette[4 * this_index + 1] = Clipboard.pal_data[current_color].g8
		new_palette[4 * this_index + 2] = Clipboard.pal_data[current_color].b8
		new_palette[4 * this_index + 3] = Clipboard.pal_data[current_color].a8
		
		current_color += 1
	
	apply_palette(new_palette)
	undo_redo.commit_action()


func paste_into() -> void:
	var current_color: int = 0
	var new_palette: PackedByteArray = sprite.palette.duplicate()
	
	for index: int in get_color_count():
		if !selection.selected[index]:
			continue
		
		new_palette[4 * index + 0] = Clipboard.pal_data[current_color].r8
		new_palette[4 * index + 1] = Clipboard.pal_data[current_color].g8
		new_palette[4 * index + 2] = Clipboard.pal_data[current_color].b8
		new_palette[4 * index + 3] = Clipboard.pal_data[current_color].a8
		
		current_color = wrapi(current_color + 1, 0, Clipboard.pal_data.size())

	apply_palette(new_palette)
	undo_redo.commit_action()


func apply_palette(new: PackedByteArray) -> void:
	undo_redo.add_do_property(sprite, "palette", new)
	undo_redo.add_do_method(signal_index_edited.bind(edit_index))
	undo_redo.add_do_method(signal_sprite_updated)
	
	undo_redo.add_undo_property(sprite, "palette", sprite.palette.duplicate())
	undo_redo.add_undo_method(signal_index_edited.bind(edit_index))
	undo_redo.add_undo_method(signal_sprite_updated)


func import(colors: PackedByteArray) -> void:
	var action_text: String
	
	# Adapt palette size to sprite bit depth
	colors.resize(4 * get_color_count())

	var new: PackedByteArray = colors.duplicate()
	
	action_text = tr("ACTION_PROVIDER_SPRITE_IMPORT").format({
		"index": edit_index
	})
	
	undo_redo.create_action(action_text)
	status_register_action(action_text)
	
	apply_palette(new)
	undo_redo.commit_action()
	
	
func reindex() -> void:
	var action_text: String = tr("ACTION_PROVIDER_PALETTE_REINDEX").format({
		"index": edit_index
	})
	
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(sprite.reindex_palette)
	undo_redo.add_do_method(signal_index_edited.bind(edit_index))
	
	undo_redo.add_undo_method(sprite.reindex_palette)
	undo_redo.add_undo_method(signal_index_edited.bind(edit_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func reorder() -> void:
	match context:
		Context.SPRITE_EDITOR:
			reorder_sprite()


func reorder_sprite() -> void:
	var action_text: String = tr("ACTION_PROVIDER_REORDER_SPRITE").format({
		"index": edit_index
	})
	
	undo_redo.create_action(action_text)
	status_register_action(action_text)
	
	var old_pixels: PackedByteArray = sprite.pixels.duplicate()
	var new_pixels: PackedByteArray = selection.get_reordered_pixels(old_pixels)
	
	undo_redo.add_do_property(sprite, "pixels", new_pixels)
	undo_redo.add_do_method(sprite.update_preview)
	
	undo_redo.add_undo_property(sprite, "pixels", old_pixels)
	undo_redo.add_undo_method(sprite.update_preview)
	
	apply_palette(selection.get_reordered_colors())
	undo_redo.commit_action()


# func apply_gradient(mode: GradientMode) -> void:
