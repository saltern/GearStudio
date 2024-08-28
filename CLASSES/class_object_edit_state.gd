# ObjectEditState
# Resource to be held in dictionary by SharedData.
class_name ObjectEditState extends Resource

signal box_selected
signal boxes_deselected
signal box_editing_toggled
signal box_updated
signal box_display_regions_changed

@warning_ignore("unused_signal")
signal cell_unloading
signal cell_loaded
signal cell_updated

var undo: UndoRedo = UndoRedo.new()

var data: ObjectData
var cell_index: int = 0
var box_index: int = 0

var this_cell: Cell
var this_box: BoxInfo

var box_edits_allowed: bool
var box_display_regions: bool


#region Serialization
func serialize_and_save(path: String) -> void:
	SaveErrors.cell_save_error = false
	
	var cell_json_array: Array[String] = data.serialize_cells()
	
	for cell in cell_json_array.size():		
		DirAccess.make_dir_recursive_absolute("%s/cells" % path)
		
		var new_json_file = FileAccess.open(
			"%s/cells/cell_%s.json" % [path, cell], FileAccess.WRITE)
		
		if FileAccess.get_open_error() != OK:
			SaveErrors.cell_save_error = true
			continue
		
		new_json_file.store_string(cell_json_array[cell])
		new_json_file.close()

	if SaveErrors.cell_save_error:
		Status.set_status("Could not save some cells!")
	else:
		Status.set_status("Saved cells.")

#region Cells
func cell_get(cell: int = 0) -> Cell:
	return data.cells[cell]


func cell_load(cell: int = 0) -> void:
	cell_unloading.emit()
	cell_index = cell
	box_index = 0
	this_cell = data.cells[cell_index]
	this_box = BoxInfo.new()
	cell_loaded.emit()
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
	undo.create_action("Cell # %s: Set sprite index" % cell_index,
			UndoRedo.MERGE_ENDS)
	
	var old_index: int = sprite_get_index()
	
	undo.add_do_property(this_cell.sprite_info, "index", new_index)
	undo.add_do_method(emit_signal.bind("cell_updated", cell_index))
			
	undo.add_undo_property(this_cell.sprite_info, "index", old_index)
	undo.add_undo_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.commit_action()


func sprite_set_position_x(new_x: int) -> void:
	undo.create_action("Cell # %s: Set sprite X offset" % cell_index,
			UndoRedo.MERGE_ENDS)
	
	var old_x: int = sprite_get_position().x
	
	undo.add_do_property(this_cell.sprite_info, "position:x", new_x)
	undo.add_do_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.add_undo_property(this_cell.sprite_info, "position:x", old_x)
	undo.add_undo_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.commit_action()


func sprite_set_position_y(new_y: int) -> void:
	undo.create_action("Cell # %s: Set sprite Y offset" % cell_index,
			UndoRedo.MERGE_ENDS)
	
	var old_y: int = sprite_get_position().y
	
	undo.add_do_property(this_cell.sprite_info, "position:y", new_y)
	undo.add_do_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.add_undo_property(this_cell.sprite_info, "position:y", old_y)
	undo.add_undo_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.commit_action()
#endregion


#region Boxes
func box_get(index: int = 0) -> BoxInfo:
	return box_get_all()[index]


func box_get_all() -> Array[BoxInfo]:
	return this_cell.boxes


func box_set_active(index: int = 0) -> void:
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
	undo.create_action("Cell #%s set box type" % cell_index,
			UndoRedo.MERGE_ENDS)
	
	undo.add_do_property(this_box, "type", new_type)
	undo.add_do_method(emit_signal.bind("box_updated", box_index))
			
	undo.add_undo_property(this_box, "type", this_box.type)
	undo.add_undo_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.commit_action()


func box_set_offset_x(new_value: int) -> void:
	undo.create_action("Cell #%s set box X offset" % cell_index,
			UndoRedo.MERGE_ENDS)
	
	undo.add_do_property(this_box, "rect:position:x", new_value)
	undo.add_do_method(emit_signal.bind("box_updated", box_index))
	
	undo.add_undo_property(this_box, "rect:position:x", this_box.rect.position.x)
	undo.add_undo_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.commit_action()


func box_set_offset_y(new_value: int) -> void:
	undo.create_action("Cell #%s set box Y offset" % cell_index,
			UndoRedo.MERGE_ENDS)
	
	undo.add_do_property(this_box, "rect:position:y", new_value)
	undo.add_do_method(emit_signal.bind("box_updated", box_index))
	
	undo.add_undo_property(this_box, "rect:position:y", this_box.rect.position.y)
	undo.add_undo_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.commit_action()


func box_set_width(new_value: int) -> void:
	undo.create_action("Cell #%s set box width" % cell_index,
			UndoRedo.MERGE_ENDS)
	
	undo.add_do_property(this_box, "rect:size:x", new_value)
	undo.add_do_method(emit_signal.bind("box_updated", box_index))
	
	undo.add_undo_property(this_box, "rect:size:x", this_box.rect.size.x)
	undo.add_undo_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.commit_action()


func box_set_height(new_value: int) -> void:
	undo.create_action("Cell #%s set box height" % cell_index,
			UndoRedo.MERGE_ENDS)
	
	undo.add_do_property(this_box, "rect:size:y", new_value)
	undo.add_do_method(emit_signal.bind("box_updated", box_index))
	
	undo.add_undo_property(this_box, "rect:size:y", this_box.rect.size.y)
	undo.add_undo_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.commit_action()


func box_set_rect_for(index: int, rect: Rect2i) -> void:
	undo.create_action("Cell #%s set box %02d rect" % [cell_index, index])
	
	var box: BoxInfo = box_get(index)
	
	undo.add_do_property(box, "rect", rect)
	undo.add_do_method(emit_signal.bind("box_updated", index))
	
	undo.add_undo_property(box, "rect", box.rect)
	undo.add_undo_method(emit_signal.bind("cell_updated", cell_index))
	
	undo.commit_action()
#endregion
