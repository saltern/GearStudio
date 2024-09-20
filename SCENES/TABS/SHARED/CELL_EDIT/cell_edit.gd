class_name CellEdit extends MarginContainer

signal palette_updated

@warning_ignore("unused_signal")
signal sprite_updated

signal box_selected
signal box_selected_index
signal box_deselected
signal box_deselected_all
signal box_editing_toggled
@warning_ignore("unused_signal")
signal box_updated
signal box_display_regions_changed
signal box_drawing_mode_changed
signal box_multi_dragged
signal box_multi_drag_stopped

signal cell_updated

var undo_redo: UndoRedo = UndoRedo.new()

var obj_data: ObjectData
var pal_data: PaletteData

var cell_index: int
var this_cell: Cell

var boxes_selected: Array[int] = []
var box_drawing_mode: bool
var box_edits_allowed: bool
var box_display_regions: bool

var palette_index: int = 0
var this_palette: BinPalette


func _enter_tree() -> void:
	obj_data = SessionData.object_data_get(get_parent().name)
	pal_data = SessionData.palette_data_get(
		get_parent().get_parent().get_index())


func _ready() -> void:
	GlobalSignals.menu_undo.connect(undo)
	GlobalSignals.menu_redo.connect(redo)
	this_palette = pal_data.palettes[0]
	cell_load(0)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
		
	if not event is InputEventKey:
		return
		
	if not event.pressed or event.echo:
		return
	
	if Input.is_action_just_pressed("undo"):
		undo()
	
	elif Input.is_action_just_pressed("redo"):
		redo()

	if Input.is_action_just_pressed("ui_copy"):
		if Input.is_key_pressed(KEY_ALT):
			var sprite_info := this_cell.sprite_info
			
			# duplicate() doesn't work here even with (true) for some reason
			var sprite_info_copy := SpriteInfo.new()
			sprite_info_copy.index = sprite_info.index
			sprite_info_copy.position = sprite_info.position
			sprite_info_copy.unknown = sprite_info.unknown
			
			Clipboard.sprite_info = sprite_info_copy
			
			Status.set_status("Copied Sprite Info for cell #%s." %
				SessionData.cell_get_index())
		
		else:
			if boxes_selected.size() == 0:
				Status.set_status("No boxes selected, nothing copied.")
			else:
				Clipboard.box_data.clear()
				
				for box in boxes_selected:
					# duplicate() doesn't work here either
					var this_box := this_cell.boxes[box]
					var new_box := BoxInfo.new()
					new_box.rect = this_box.rect
					new_box.type = this_box.type
					new_box.crop_x_offset = this_box.crop_x_offset
					new_box.crop_y_offset = this_box.crop_y_offset
					
					Clipboard.box_data.append(new_box)
				
				Status.set_status("Copied box(es).")

	if Input.is_action_just_pressed("ui_paste"):
		if Input.is_key_pressed(KEY_ALT):
			SessionData.sprite_info_paste()

		elif Input.is_key_pressed(KEY_SHIFT):
			SessionData.box_paste(true)
		
		else:
			SessionData.box_paste(false)


#region Undo/Redo
func undo() -> void:
	if not is_visible_in_tree():
		return
	
	undo_redo.undo()


func redo() -> void:
	if not is_visible_in_tree():
		return
	
	undo_redo.redo()
#endregion


#region Serialization
func serialize_and_save(path: String) -> void:	
	var cell_json_array: Array[String] = obj_data.serialize_cells()
	
	for cell in cell_json_array.size():		
		DirAccess.make_dir_recursive_absolute("%s/cells" % path)
		
		var new_json_file = FileAccess.open(
			"%s/cells/cell_%s.json" % [path, cell], FileAccess.WRITE)
		
		if FileAccess.get_open_error() != OK:
			SaveErrors.cell_save_error = true
			continue
		
		new_json_file.store_string(cell_json_array[cell])
		new_json_file.close()
#endregion


#region Palettes
func palette_load(index: int) -> void:
	palette_index = index
	this_palette = pal_data.palettes[index]
	palette_updated.emit(this_palette)
#endregion


#region Cells
func cell_get_count() -> int:
	return obj_data.cells.size()


func cell_get_index() -> int:
	return cell_index


func cell_get(index: int) -> Cell:
	return obj_data.cells[index]


func cell_load(index: int) -> void:
	cell_index = index
	this_cell = obj_data.cells[cell_index]
	cell_updated.emit(this_cell)
	boxes_selected.resize(0)


func cell_ensure_selected(cell: Cell) -> void:
	if this_cell != cell:
		cell_updated.emit(cell)
#endregion


#region Sprites
func sprite_get(index: int = 0) -> BinSprite:
	return obj_data.sprites[index]
	
	
func sprite_get_count() -> int:
	return obj_data.sprites.size()
#endregion


#region Sprite Info
func sprite_get_index() -> int:
	return this_cell.sprite_info.index
	
	
func sprite_get_position() -> Vector2i:
	return this_cell.sprite_info.position


func sprite_set_index(new_index: int) -> void:
	undo_redo.create_action("Cell # %s: Set sprite index" % cell_index,
		UndoRedo.MERGE_ENDS)
	
	var old_index: int = sprite_get_index()
	
	undo_redo.add_do_property(this_cell.sprite_info, "index", new_index)
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
			
	undo_redo.add_undo_property(this_cell.sprite_info, "index", old_index)
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.commit_action()


func sprite_set_position_x(new_x: int) -> void:	
	undo_redo.create_action("Cell # %s: Set sprite X offset" % cell_index,
		UndoRedo.MERGE_ENDS)
	
	var old_pos: Vector2i = sprite_get_position()
	
	undo_redo.add_do_property(this_cell.sprite_info, "position", Vector2i(
			new_x, old_pos.y))
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.add_undo_property(this_cell.sprite_info, "position", old_pos)
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.commit_action()


func sprite_set_position_y(new_y: int) -> void:
	undo_redo.create_action("Cell # %s: Set sprite Y offset" % cell_index,
		UndoRedo.MERGE_ENDS)
	
	var old_pos: Vector2i = sprite_get_position()
	
	undo_redo.add_do_property(this_cell.sprite_info, "position", Vector2i(
			old_pos.x, new_y))
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.add_undo_property(this_cell.sprite_info, "position", old_pos)
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.commit_action()


func sprite_info_paste() -> void:
	if Clipboard.sprite_info == null:
		Status.set_status("No Sprite Info on clipboard, nothing pasted.")
		return
	
	undo_redo.create_action("Cell #%s paste Sprite Info" % cell_index)
	
	var new_sprite_info := SpriteInfo.new()
	
	new_sprite_info.index = Clipboard.sprite_info.index
	new_sprite_info.position = Clipboard.sprite_info.position
	new_sprite_info.unknown = Clipboard.sprite_info.unknown
	
	undo_redo.add_do_property(this_cell, "sprite_info", new_sprite_info)
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.add_undo_property(this_cell, "sprite_info", this_cell.sprite_info)
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.commit_action()
#endregion


#region Boxes
func box_get(index: int = 0) -> BoxInfo:
	return box_get_all()[index]


func box_get_all() -> Array[BoxInfo]:
	return this_cell.boxes


func box_set_selection(list: PackedInt32Array) -> void:
	boxes_selected.clear()
	
	for item in list:
		boxes_selected.append(item)
		box_selected.emit(box_get(item))
	
	for item in this_cell.boxes.size():
		if not item in boxes_selected:
			box_deselected.emit(item)


func box_select(index: int) -> void:
	boxes_selected.append(index)
	box_selected.emit(box_get(index))
	box_selected_index.emit(index)


func box_deselect(index: int) -> void:
	boxes_selected.remove_at(boxes_selected.find(index))
	box_deselected.emit(index)


func box_deselect_all() -> void:
	box_deselected_all.emit()
	boxes_selected.clear()


func box_set_editing(enabled: bool) -> void:
	box_edits_allowed = enabled
	box_editing_toggled.emit(enabled)
	box_deselect_all()


func box_set_display_regions(enabled: bool) -> void:
	box_display_regions = enabled
	box_display_regions_changed.emit()


func box_set_draw_mode(enabled: bool) -> void:
	box_drawing_mode = enabled
	box_drawing_mode_changed.emit(enabled)


func box_append(box: BoxInfo) -> void:
	undo_redo.create_action("Cell #%s add box" % cell_index)
	
	undo_redo.add_do_method(box_append_commit.bind(this_cell, box))
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.add_undo_method(box_delete_commit.bind(this_cell, box))
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.commit_action()
	
	Status.set_status("Added new box.")


func box_delete() -> void:
	if boxes_selected.size() == 0:
		Status.set_status("No boxes selected, can't delete.")
		return
	
	if boxes_selected.size() > 1:
		undo_redo.create_action("Cell #%s delete boxes (%s)" %
			[cell_index, Engine.get_physics_frames()], UndoRedo.MERGE_ALL)
	else:
		undo_redo.create_action("Cell #%s delete box" % cell_index)
	
	
	for box_index in boxes_selected:
		var deleted_box: BoxInfo = box_get(box_index)
		
		undo_redo.add_do_method(box_delete_commit.bind(this_cell, deleted_box))
		undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
		
		undo_redo.add_undo_method(box_append_commit.bind(this_cell, deleted_box, box_index))
		undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
		
	undo_redo.commit_action()	
	Status.set_status("Deleted box.")


func box_append_commit(cell: Cell, box: BoxInfo, index: int = -1) -> void:
	if index < 0:
		cell.boxes.append(box)
	else:
		cell.boxes.insert(index, box)


func box_delete_commit(cell: Cell, box: BoxInfo) -> void:
	cell.boxes.remove_at(cell.boxes.find(box))


func box_paste(overwrite: bool = false) -> void:
	if Clipboard.box_data.size() == 0:
		Status.set_status("No boxes on clipboard, nothing pasted.")
	
	if overwrite:
		undo_redo.create_action("Cell #%s paste boxes with overwrite" % cell_index)
	else:
		undo_redo.create_action("Cell #%s paste boxes" % cell_index)
	
	for box in Clipboard.box_data:
		undo_redo.add_do_method(box_append_commit.bind(this_cell, box))
		undo_redo.add_undo_method(box_delete_commit.bind(this_cell, box))
		
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.commit_action()
	
	Status.set_status("Pasted box(es).")


func box_set_type(new_type: int) -> void:
	if boxes_selected.size() == 0:
		return

	if boxes_selected.size() > 1:
		undo_redo.create_action(
			"Cell #%s set type for multiple boxes (%s)" %
			[cell_index, Engine.get_physics_frames()], UndoRedo.MERGE_ALL)
	else:
		undo_redo.create_action("Cell #%s set box type" % cell_index,
			UndoRedo.MERGE_ENDS)
	
	for box in boxes_selected:
		var current_box: BoxInfo = this_cell.boxes[box]
		
		undo_redo.add_do_property(current_box, "type", new_type)
		undo_redo.add_do_method(cell_ensure_selected.bind(this_cell))
		undo_redo.add_do_method(emit_signal.bind("box_updated", current_box))
			
		undo_redo.add_undo_property(current_box, "type", current_box.type)
		undo_redo.add_undo_method(cell_ensure_selected.bind(this_cell))
		undo_redo.add_undo_method(emit_signal.bind("box_updated", current_box))
	
	Status.set_status("Set box type.")
	undo_redo.commit_action()


func box_multi_drag(index: int, motion: Vector2) -> void:
	box_multi_dragged.emit(index, motion)


func box_multi_drag_stop(index: int) -> void:
	box_multi_drag_stopped.emit(index)


func box_set_offset_x(new_value: int) -> void:
	undo_redo.create_action("Cell #%s set box X offset" % cell_index,
		UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	var new_rect: Rect2i = this_box.rect
	new_rect.position.x = new_value
	
	undo_redo.add_do_property(this_box, "rect", new_rect)
	undo_redo.add_do_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "rect", this_box.rect)
	undo_redo.add_undo_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.commit_action()


func box_set_offset_y(new_value: int) -> void:
	undo_redo.create_action("Cell #%s set box Y offset" % cell_index,
		UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	var new_rect: Rect2i = this_box.rect
	new_rect.position.y = new_value
	
	undo_redo.add_do_property(this_box, "rect", new_rect)
	undo_redo.add_do_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "rect", this_box.rect)
	undo_redo.add_undo_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.commit_action()


func box_set_width(new_value: int) -> void:
	undo_redo.create_action("Cell #%s set box width" % cell_index,
		UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	var new_rect: Rect2i = this_box.rect
	new_rect.size.x = new_value
	
	undo_redo.add_do_property(this_box, "rect", new_rect)
	undo_redo.add_do_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "rect", this_box.rect)
	undo_redo.add_undo_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.commit_action()


func box_set_height(new_value: int) -> void:
	undo_redo.create_action("Cell #%s set box height" % cell_index,
		UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	var new_rect: Rect2i = this_box.rect
	new_rect.size.y = new_value
	
	undo_redo.add_do_property(this_box, "rect", new_rect)
	undo_redo.add_do_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "rect", this_box.rect)
	undo_redo.add_undo_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.commit_action()


func box_set_rect_for(index: int, rect: Rect2i) -> void:
	if boxes_selected.size() > 1:
		undo_redo.create_action(
			"Cell #%s set multiple box rects (%s)" %
			[cell_index, Engine.get_physics_frames()], UndoRedo.MERGE_ALL)
	else:
		undo_redo.create_action("Cell #%s set box %02d rect" % [cell_index, index])
	
	var box: BoxInfo = box_get(index)
	
	undo_redo.add_do_property(box, "rect", rect)
	undo_redo.add_do_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_do_method(emit_signal.bind("box_updated", box))
	
	undo_redo.add_undo_property(box, "rect", box.rect)
	undo_redo.add_undo_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", box))
	
	undo_redo.commit_action()


func box_set_crop_offset_x(new_value: int) -> void:
	undo_redo.create_action("Cell #%s set sprite region crop X offset" % cell_index,
		UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	undo_redo.add_do_property(this_box, "crop_x_offset", new_value)
	undo_redo.add_do_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "crop_x_offset", this_box.crop_x_offset)
	undo_redo.add_undo_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.commit_action()


func box_set_crop_offset_y(new_value: int) -> void:
	undo_redo.create_action("Cell #%s set sprite region crop Y offset" % cell_index,
		UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	undo_redo.add_do_property(this_box, "crop_y_offset", new_value)
	undo_redo.add_do_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "crop_y_offset", this_box.crop_y_offset)
	undo_redo.add_undo_method(cell_ensure_selected.bind(this_cell))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.commit_action()
#endregion