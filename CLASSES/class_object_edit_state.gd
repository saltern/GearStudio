# ObjectEditState
# Resource to be held in dictionary by SharedData.
class_name ObjectEditState extends Resource

signal selected_box
signal deselected_boxes
signal box_editing_toggled

var data: ObjectData
var cell_index: int = 0
var box_index: int = 0

var this_cell: Cell
var this_box: BoxInfo

var box_edits_allowed: bool
var box_display_regions: bool


func get_sprite(index: int = 0) -> BinSprite:
	return data.sprites[index]


func get_cell(cell: int = 0) -> Cell:
	cell_index = cell
	box_index = 0
	this_cell = data.cells[cell_index]
	this_box = BoxInfo.new()
	
	return this_cell


func get_box(index: int = 0) -> BoxInfo:
	box_index = index
	return get_boxes()[box_index]


func get_boxes() -> Array[BoxInfo]:
	return this_cell.boxes


func select_box(index: int = 0) -> void:
	get_box(index)
	selected_box.emit(index)


func box_list_empty_clicked(_ignored1, _ignored2) -> void:
	deselect_boxes()


func deselect_boxes() -> void:
	box_index = -1
	deselected_boxes.emit()


func set_box_editing(enabled: bool) -> void:
	box_edits_allowed = enabled
	box_editing_toggled.emit(enabled)
	deselect_boxes()


func set_box_regions(enabled: bool) -> void:
	box_display_regions = enabled
	
