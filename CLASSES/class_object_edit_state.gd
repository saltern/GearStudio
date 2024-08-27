# ObjectEditState
# Resource to be held in dictionary by SharedData.
class_name ObjectEditState extends Resource

signal box_selected
signal boxes_deselected
signal box_editing_toggled
signal box_updated
signal box_display_regions_changed

@warning_ignore("unused_signal")
signal cell_updated

var undo: UndoRedo = UndoRedo.new()

var data: ObjectData
var cell_index: int = 0
var box_index: int = 0

var this_cell: Cell
var this_box: BoxInfo

var box_edits_allowed: bool
var box_display_regions: bool


#region Undo/redo
func action_undo() -> void:
	undo.undo()


func action_redo() -> void:
	undo.redo()
#endregion


#region Cells
func cell_get(cell: int = 0) -> Cell:
	return data.cells[cell]


func cell_load(cell: int = 0) -> void:
	cell_index = cell
	box_index = 0
	this_cell = data.cells[cell_index]
	this_box = BoxInfo.new()
#endregion


#region Sprites
func sprite_get(index: int = 0) -> BinSprite:
	return data.sprites[index]


func sprite_get_index() -> int:
	return this_cell.sprite_info.index


func sprite_get_position() -> Vector2i:
	return this_cell.sprite_info.position


func sprite_get_count() -> int:
	return data.sprites.size()


func sprite_set_index(new_index: int) -> void:
	undo.create_action("Set sprite index")
	
	var old_index: int = sprite_get_index()
	
	undo.add_do_property(this_cell.sprite_info, "index", new_index)
	undo.add_do_method(emit_signal.bind("cell_updated", cell_index))
			
	undo.add_undo_property(this_cell.sprite_info, "index", old_index)
	undo.add_undo_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.commit_action()
#endregion


#region Boxes
func box_get(index: int = 0) -> BoxInfo:
	return box_get_all()[index]


func box_get_all() -> Array[BoxInfo]:
	return this_cell.boxes


func box_select(index: int = 0) -> void:
	box_index = index
	this_box = box_get(box_index)
	box_selected.emit(index)


func box_list_empty_clicked(_ignored1, _ignored2) -> void:
	box_deselect()


func box_deselect() -> void:
	this_box = BoxInfo.new()
	box_index = -1
	boxes_deselected.emit()


func box_set_editing(enabled: bool) -> void:
	box_edits_allowed = enabled
	box_editing_toggled.emit(enabled)
	box_deselect()


func box_set_display_regions(enabled: bool) -> void:
	box_display_regions = enabled
	box_display_regions_changed.emit()


func box_set_type(new_type: int) -> void:
	undo.create_action("Set box type")
	
	undo.add_do_property(this_box, "type", new_type)
	undo.add_do_method(emit_signal.bind("cell_updated", box_index))
			
	undo.add_undo_property(this_box, "type", this_box.type)
	undo.add_undo_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.commit_action()
	
	#this_box.type = new_type
	#box_updated.emit(box_index)


func box_set_offset_x(new_value: int) -> void:
	this_box.rect.position.x = new_value
	box_updated.emit(box_index)


func box_set_offset_y(new_value: int) -> void:
	this_box.rect.position.y = new_value
	box_updated.emit(box_index)


func box_set_width(new_value: int) -> void:
	this_box.rect.size.x = new_value
	box_updated.emit(box_index)


func box_set_height(new_value: int) -> void:
	this_box.rect.size.y = new_value
	box_updated.emit(box_index)


func box_set_rect(rect: Rect2i) -> void:
	this_box.rect = rect
	box_updated.emit(box_index)


func box_set_rect_for(index: int, rect: Rect2i) -> void:
	box_get(index).rect = rect
	box_updated.emit(box_index)
#endregion
