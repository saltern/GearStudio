# SessionData autoload
extends Node

@warning_ignore("unused_signal")
signal tab_loading_complete
signal tab_closed

var tab_index: int = 0
var object_name: String
var tabs: Array = []

var this_tab: Dictionary = {}
var this_object_state: ObjectEditState
var this_palette_state: PaletteEditState

var serialize_ignore: Array[String] = ["path", "current_object", "palettes"]

# tabs = [
#	{
#		"current_object": "player",
#		"palettes": PaletteEditState,
#		"player": ObjectEditState,
#		"objno0": ObjectEditState,
#		"objno1": ObjectEditState,
#	},
#
#	...


#region Undo/redo
func menu_undo() -> void:
	if tabs.size() == 0:
		Status.set_status("Nothing currently loaded, can't undo.")
		return
		
	if this_tab["current_object"] == "palettes":
		undo_pal()
	else:
		undo()


func menu_redo() -> void:
	if tabs.size() == 0:
		Status.set_status("Nothing currently loaded, can't redo.")
		return
		
	if this_tab["current_object"] == "palettes":
		redo_pal()
	else:
		redo()


func undo() -> void:
	if not this_object_state.undo.has_undo():
		Status.set_status("Nothing to undo.")
		return
		
	var action_name: String = this_object_state.undo.get_current_action_name()
	Status.set_status("Undo: %s" % action_name)
	
	this_object_state.undo.undo()


func redo() -> void:
	if not this_object_state.undo.has_redo():
		Status.set_status("Nothing to redo.")
		return
		
	this_object_state.undo.redo()
	
	var action_name: String = this_object_state.undo.get_current_action_name()
	Status.set_status("Redo: %s" % action_name)


func undo_pal() -> void:
	if not this_palette_state.undo.has_undo():
		Status.set_status("Nothing to undo.")
		return
	
	Status.set_status("Undo: %s" % 
			this_palette_state.undo.get_current_action_name())
			
	this_palette_state.undo.undo()


func redo_pal() -> void:
	if not this_palette_state.undo.has_redo():
		Status.set_status("Nothing to redo.")
		return
			
	this_palette_state.undo.redo()
	
	Status.set_status("Redo: %s" % 
			this_palette_state.undo.get_current_action_name())
#endregion


func save() -> void:
	SaveErrors.reset()
	
	if this_tab.is_empty():
		Status.set_status("Nothing to save.")
		return
	
	if not this_tab.has("path"):
		Status.set_status("Could not save! Cause: malformed dictionary")
		return
	
	var save_path: String = this_tab["path"]
	
	for object in this_tab:
		if object in serialize_ignore:
			continue
		
		this_tab[object].serialize_and_save(save_path + "/%s" % object)
	
	if this_tab.has("palettes"):
		this_tab["palettes"].serialize_and_save(save_path + "/palettes")

	SaveErrors.set_status()

#region Tabs
func tab_new(path: String) -> void:
	var sub_tab_list: PackedStringArray = []
	
	var dir: DirAccess = DirAccess.open(path)
	
	if DirAccess.get_open_error() != OK:
		Status.set_status(
				"Could not load character! Reason: Could not open directory.")
		call_deferred("emit_signal", "tab_loading_complete", path, sub_tab_list)
		return
	
	var new_session: Dictionary = {}
	var dir_list: PackedStringArray = dir.get_directories()
	
	# Palettes loaded separately
	if dir.dir_exists("palettes"):
		var palette_data := PaletteEditState.new()
		
		palette_data.load_palettes_from_path(path + "/palettes")
		new_session["palettes"] = palette_data
		
		dir_list.remove_at(dir_list.find("palettes"))
		sub_tab_list.append("palettes")
	
	if dir_list.size() < 1:
		call_deferred("emit_signal", "tab_loading_complete", path, sub_tab_list)
		return
		
	
	new_session["current_object"] = dir_list[0]
	
	# Load objects
	for directory in dir_list:
		var object_data := ObjectData.new()
		
		if DirAccess.dir_exists_absolute(path + "/%s/sprites" % directory):
			object_data.load_sprites_from_path(path + "/%s/sprites" % directory)
		
		if DirAccess.dir_exists_absolute(path + "/%s/cells" % directory):
			object_data.load_cells_from_path(path + "/%s/cells" % directory)
		
		if object_data.sprites.is_empty() and object_data.cells.is_empty():
			continue
		
		var object_edit_state := ObjectEditState.new()
		object_edit_state.data = object_data
		
		new_session[directory] = object_edit_state
		sub_tab_list.append(directory)
	
	if !sub_tab_list.is_empty():
		tabs.append(new_session)
		this_tab = new_session
		this_tab["path"] = path
		object_state_load(dir_list[0])
	
	call_deferred("emit_signal", "tab_loading_complete", path, sub_tab_list)


func tab_load(index: int = 0) -> void:
	if index < 0 || index >= tabs.size():
		Status.set_ready()
		return
	
	tab_index = index
	this_tab = tabs[index]
	this_palette_state = palette_state_get(tab_index)


func tab_close(index: int = 0) -> void:
	if tabs.size() < 1:
		Status.set_status("Nothing currently open, can't close.")
		return
	
	tab_closed.emit(index)
	tabs.remove_at(tab_index)
	this_tab = {}
	tab_load(min(tab_index, tabs.size() - 1))
	Status.set_status("Closed tab.")
#endregion


func object_state_load(object: String) -> void:
	this_tab["current_object"] = object
	this_object_state = object_state_get(object)


func object_state_get(object: String) -> ObjectEditState:
	return this_tab[object]


func palette_state_get(from_tab: int) -> PaletteEditState:
	return tabs[from_tab]["palettes"]


# Redirects
#region Palettes
func palette_load(number: int = 0) -> void:
	this_object_state.load_palette(number)


func palette_get_color_array() -> PackedByteArray:
	return this_object_state.get_palette_colors()


func palette_get_color(index: int = 0) -> Color:
	return this_object_state.get_color(index)


func palette_set_color(index: int, color: Color) -> void:
	this_object_state.set_color(index, color)
#endregion


#region Sprites
func sprite_get(index: int = 0) -> BinSprite:
	return this_object_state.sprite_get(index)


func sprite_get_count() -> int:
	return this_object_state.data.sprites.size()


func sprite_set_index(new_index: int) -> void:
	this_object_state.sprite_set_index(new_index)


func sprite_set_position_x(new_position: int) -> void:
	this_object_state.sprite_set_position_x(new_position)


func sprite_set_position_y(new_position: int) -> void:
	this_object_state.sprite_set_position_y(new_position)
#endregion


#region Cells
func cell_get(index: int = 0) -> Cell:
	return this_object_state.cell_get(index)


func cell_get_this() -> Cell:
	return this_object_state.this_cell


func cell_set_this(index: int = 0) -> void:
	this_object_state.this_cell = cell_get(index)


func cell_get_index() -> int:
	return this_object_state.cell_index
#endregion


#region Sprite Info
func sprite_info_paste() -> void:
	this_object_state.sprite_info_paste()
#endregion


#region Boxes
func box_get(index: int) -> BoxInfo:
	return this_object_state.data.get_boxes()[index]


func box_get_this() -> BoxInfo:
	return this_object_state.this_box


func box_set_selection(list: PackedInt32Array) -> void:
	this_object_state.box_set_selection(list)


func box_select(index: int) -> void:
	this_object_state.box_select(index)


func box_deselect(index: int) -> void:
	this_object_state.box_deselect(index)


func box_deselect_all() -> void:
	this_object_state.box_deselect_all()


func box_get_selected() -> Array[int]:
	return this_object_state.boxes_selected


func box_get_selected_count() -> int:
	return this_object_state.boxes_selected.size()


func box_set_editing(enabled: bool) -> void:
	this_object_state.box_set_editing(enabled)


func box_get_edits_allowed() -> bool:
	return this_object_state.box_edits_allowed


func box_get_display_regions() -> bool:
	return this_object_state.box_display_regions


func box_set_display_regions(enabled: bool) -> void:
	this_object_state.box_set_display_regions(enabled)


func box_set_draw_mode(enabled: bool) -> void:
	this_object_state.box_set_draw_mode(enabled)


func box_get_draw_mode() -> bool:
	return this_object_state.box_drawing_mode


func box_append(box: BoxInfo) -> void:
	this_object_state.box_append(box)


func box_delete() -> void:
	this_object_state.box_delete()


func box_paste(overwrite: bool = false) -> void:
	this_object_state.box_paste(overwrite)


func box_set_type(new_type: int) -> void:
	Status.set_status("Set box type.")
	this_object_state.box_set_type(new_type)


func box_multi_drag(index: int, motion: Vector2) -> void:
	this_object_state.box_multi_drag(index, motion)


func box_multi_drag_stop(index: int) -> void:
	this_object_state.box_multi_drag_stop(index)


func box_set_offset_x(new_value: int) -> void:
	Status.set_status("Set box X offset.")
	this_object_state.box_set_offset_x(new_value)


func box_set_offset_y(new_value: int) -> void:
	Status.set_status("Set box Y offset.")
	this_object_state.box_set_offset_y(new_value)


func box_set_width(new_value: int) -> void:
	Status.set_status("Set box width.")
	this_object_state.box_set_width(new_value)


func box_set_height(new_value: int) -> void:
	Status.set_status("Set box height.")
	this_object_state.box_set_height(new_value)


func box_set_rect_for(index: int, rect: Rect2i) -> void:
	Status.set_status("Set box rect.")
	this_object_state.box_set_rect_for(index, rect)


func box_set_crop_offset_x(new_value: int) -> void:
	Status.set_status("Set sprite region X offset.")
	this_object_state.box_set_crop_offset_x(new_value)


func box_set_crop_offset_y(new_value: int) -> void:
	Status.set_status("Set sprite region Y offset.")
	this_object_state.box_set_crop_offset_y(new_value)
#endregion
