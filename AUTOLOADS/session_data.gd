# SessionData autoload
extends Node

#signal box_updated
#signal box_display_regions_changed

var tab_index: int = 0
var object_name: String
var tabs: Dictionary = {}

var this_tab: Dictionary = {}
var this_object_state: ObjectEditState
var this_palette_state: PaletteEditState

# sessions = {
#		0:	{
#				"current_object": "player",
#				"palettes": PaletteEditState,
#				"player": ObjectEditState,
#				"objno0": ObjectEditState,
#				"objno1": ObjectEditState,
#		},


func undo() -> void:
	this_object_state.action_undo()


func redo() -> void:
	this_object_state.action_redo()


func tab_new(path: String) -> PackedStringArray:
	var sub_tab_list: PackedStringArray = []
	
	var dir: DirAccess = DirAccess.open(path)
	
	if DirAccess.get_open_error() != OK:
		print("Could not load character!")
		return sub_tab_list
	
	var new_session: Dictionary = {}
	var dir_list: PackedStringArray = dir.get_directories()
	
	# Palettes loaded separately
	if dir.dir_exists("palettes"):
		var palette_data := PaletteEditState.new()
		palette_data.load_palettes_from_path(path + "/palettes")
		new_session["palettes"] = palette_data
		
		dir_list.remove_at(dir_list.find("palettes"))
		sub_tab_list.append("palettes")
	
	new_session["current_object"] = dir_list[0]
	
	# Load objects
	for directory in dir_list:
		var object_data := ObjectData.new()
		object_data.load_sprites_from_path(path + "/%s/sprites" % directory)
		object_data.load_cells_from_path(path + "/%s/cells" % directory)
		
		var object_edit_state := ObjectEditState.new()
		object_edit_state.data = object_data
		
		new_session[directory] = object_edit_state
		sub_tab_list.append(directory)
	
	
	tabs[tabs.size()] = new_session
	this_tab = tabs[tabs.size() - 1]
	object_state_load(dir_list[0])
	
	return sub_tab_list


func tab_load(index: int = 0) -> void:
	tab_index = index
	this_tab = tabs[index]
	this_palette_state = palette_state_get(tab_index)


func object_state_load(object: String) -> void:
	this_tab["current_object"] = object
	this_object_state = object_state_get(object)


func object_state_get(object: String) -> ObjectEditState:
	return this_tab[object]


func palette_state_get(from_tab: int) -> PaletteEditState:
	return tabs[from_tab]["palettes"]


# Redirects
func palette_load(number: int = 0) -> void:
	this_object_state.load_palette(number)


func palette_get_color_array() -> PackedByteArray:
	return this_object_state.get_palette_colors()


func palette_get_color(index: int = 0) -> Color:
	return this_object_state.get_color(index)


func palette_set_color(index: int, color: Color) -> void:
	this_object_state.set_color(index, color)


#region Sprites
func sprite_get(index: int = 0) -> BinSprite:
	return this_object_state.sprite_get(index)


func sprite_get_count() -> int:
	return this_object_state.data.sprites.size()


func sprite_set_index(new_index: int) -> void:
	this_object_state.sprite_set_index(new_index)


func sprite_set_position_x(new_position: int) -> void:
	this_object_state.this_cell.sprite_info.position.x = new_position


func sprite_set_position_y(new_position: int) -> void:
	this_object_state.this_cell.sprite_info.position.y = new_position
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


#region Boxes
func box_get(index: int = 0) -> BoxInfo:
	return this_object_state.box_get(index)


func box_get_this() -> BoxInfo:
	return this_object_state.this_box


func box_get_all() -> Array[BoxInfo]:
	return this_object_state.box_get_all()


func box_select(index: int = 0) -> void:
	this_object_state.box_select(index)


func box_deselect() -> void:
	this_object_state.box_deselect()


func box_set_editing(enabled: bool) -> void:
	this_object_state.box_set_editing(enabled)


func box_get_edits_allowed() -> bool:
	return this_object_state.box_edits_allowed


func box_get_display_regions() -> bool:
	return this_object_state.box_display_regions


func box_set_display_regions(enabled: bool) -> void:
	this_object_state.box_set_display_regions(enabled)


func box_set_type(new_type: int) -> void:
	this_object_state.box_set_type(new_type)


func box_set_offset_x(new_value: int) -> void:
	this_object_state.box_set_offset_x(new_value)


func box_set_offset_y(new_value: int) -> void:
	this_object_state.box_set_offset_y(new_value)


func box_set_width(new_value: int) -> void:
	this_object_state.box_set_width(new_value)


func box_set_height(new_value: int) -> void:
	this_object_state.box_set_height(new_value)


func box_set_rect(rect: Rect2i) -> void:
	this_object_state.box_set_rect(rect)


func box_set_rect_for(index: int, rect: Rect2i) -> void:
	this_object_state.box_set_rect_for(index, rect)
#endregion
