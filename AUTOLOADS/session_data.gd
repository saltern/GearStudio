# SessionData autoload
extends Node

var tab_index: int = 0
var object_name: String
var tabs: Dictionary = {}

var this_tab: Dictionary = {}
var this_object_state: ObjectEditState

# sessions = {
#		0:	{
#				"current_object": "player",
#				"palettes": PaletteEditState,
#				"player": ObjectEditState,
#				"objno0": ObjectEditState,
#				"objno1": ObjectEditState,
#		},
#
#		1:	{
#				...
#


func new_tab(path: String) -> PackedStringArray:
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
	load_object_state(dir_list[0])
	
	return sub_tab_list


func load_tab(index: int = 0) -> void:
	tab_index = index
	this_tab = tabs[index]


func load_object_state(object_name: String) -> void:
	this_tab["current_object"] = object_name
	this_object_state = get_object_state(object_name)


func get_object_state(object_name: String) -> ObjectEditState:
	return this_tab[object_name]


func get_palette_state(tab_index: int) -> PaletteEditState:
	return tabs[tab_index]["palettes"]


# Stubs
func load_palette(number: int = 0) -> void:
	this_object_state.load_palette(number)


func get_palette_colors() -> PackedByteArray:
	return this_object_state.get_palette_colors()


func get_color(index: int = 0) -> Color:
	return this_object_state.get_color(index)


func set_color(index: int, color: Color) -> void:
	this_object_state.set_color(index, color)


func get_sprite(index: int = 0) -> BinSprite:
	return this_object_state.get_sprite(index)


func get_cell(cell: int = 0) -> Cell:
	return this_object_state.get_cell(cell)


func get_cell_index() -> int:
	return this_object_state.cell_index


func get_box(index: int = 0) -> BoxInfo:
	return this_object_state.get_box(index)


func get_boxes() -> Array[BoxInfo]:
	return this_object_state.get_boxes()


func select_box(index: int = 0) -> void:
	this_object_state.select_box(index)


func deselect_boxes() -> void:
	this_object_state.deselect_boxes()


func set_box_editing(enabled: bool) -> void:
	this_object_state.set_box_editing(enabled)
