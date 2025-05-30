class_name CellEdit extends MarginContainer

@warning_ignore("unused_signal")
signal sprite_updated

signal box_selected
signal box_selected_index
signal box_deselected
signal box_deselected_all
signal box_editing_toggled
@warning_ignore("unused_signal")
signal box_updated
signal box_drawing_mode_changed
signal box_multi_dragged
signal box_multi_drag_stopped

@warning_ignore("unused_signal")
signal cell_count_changed
signal cell_updated

signal cell_snapshots_start
signal cell_snapshot_taken
signal cell_snapshots_done

@export_group("Boxes")
@export var box_draw_node: Control
@export var box_type_menu: Button
@export var box_edit_mode: Button

@export_group("Snapshots")
@export var origin_textures: Array[Texture2D] = []

var session_id: int
var undo_redo: UndoRedo = UndoRedo.new()

var obj_data: Dictionary
var ref_handler: ReferenceHandler = ReferenceHandler.new()

var cell_index: int
var this_cell: Cell
var cell_clipboard: Cell

var display_boxes: bool = true
var boxes_selected: PackedInt32Array = []
var box_drawing_mode: bool
var box_edits_allowed: bool

var box_type_ids: Array[PackedInt32Array] = [
	# Hitbox
	[0, 1],
	# Hurtbox
	[2],
	# Region (back and front)
	[3, 6],
	# Collision extension
	[4],
	# Spawn point
	[5],
	# Unknown type (>=this)
	[7],
]

var box_display_types: Array[bool] = [
	true, true, true, true, true, true, true, true
]

var provider: PaletteProvider = PaletteProvider.new()

var waiting_tasks: Array[int] = []


func _enter_tree() -> void:
	undo_redo.max_steps = Settings.misc_max_undo
	
	if not obj_data.has("cells"):
		queue_free()
		return
	
	provider.obj_data = obj_data


func _ready() -> void:
	if is_queued_for_deletion():
		return

	GlobalSignals.menu_undo.connect(undo)
	GlobalSignals.menu_redo.connect(redo)
	SpriteImport.sprite_placement_finished.connect(on_sprites_imported)
	
	if obj_data.has("palettes"):
		SessionData.palette_changed.connect(palette_set_session)
	
	SessionData.sprite_reindexed.connect(on_sprite_reindexed)
	
	provider.palette_load()
	
	cell_load(0)


func _physics_process(_delta: float) -> void:
	for task in waiting_tasks:
		if WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			waiting_tasks.pop_at(waiting_tasks.find(task))


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
			Clipboard.set_sprite_info(this_cell)
			
			Status.set_status(tr("STATUS_CELL_EDIT_SPRITE_INFO_COPY").format({
				"index": cell_get_index()
			}))
		
		else:
			if boxes_selected.size() == 0:
				Status.set_status("STATUS_CELL_EDIT_BOX_COPY_NOTHING")
			
			else:
				var array: Array[BoxInfo] = []
				
				for box in boxes_selected:
					array.append(this_cell.boxes[box])
				
				Clipboard.set_box_data(array)
				
				Status.set_status("STATUS_CELL_EDIT_BOX_COPY")

	elif Input.is_action_just_pressed("ui_paste"):
		if Input.is_key_pressed(KEY_ALT):
			sprite_info_paste()

		elif Input.is_key_pressed(KEY_SHIFT):
			box_paste(true)
		
		else:
			box_paste(false)

	if Input.is_action_just_pressed("ui_text_delete"):
		box_delete()


func set_session_id(new_id: int) -> void:
	session_id = new_id


func status_register_action(action_text: String) -> void:
	undo_redo.add_do_method(Status.set_status.bind(action_text))
	undo_redo.add_undo_method(Status.set_status.bind(tr("ACTION_UNDO").format({
		"action": action_text
	})))


#region Undo/Redo
func undo() -> void:
	if not is_visible_in_tree():
		return
	
	if not undo_redo.has_undo():
		Status.set_status("ACTION_NO_UNDO")
		return
	
	undo_redo.undo()


func redo() -> void:
	if not is_visible_in_tree():
		return
	
	if not undo_redo.has_redo():
		Status.set_status("ACTION_NO_REDO")
		return
	
	undo_redo.redo()
#endregion


#region Palettes
func palette_set_session(for_session: int, index: int) -> void:
	if for_session != session_id:
		return
	
	provider.palette_load(index)


func on_sprite_palette_changed(
	for_session: int, object: Dictionary, index: int
) -> void:
	if for_session != session_id:
		return
	
	if object != obj_data:
		return
	
	if index == sprite_get_index():
		provider.palette_reload()
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
	
	Status.set_status(tr("STATUS_CELL_EDIT_CELL_LOAD").format({
		"index": index
	}))
	
	# Reference
	ref_handler.cell_load(index)


func cell_ensure_selected(cell: int) -> void:
	if cell_index != cell:
		cell_load(cell)


# Toolbar buttons
# Delete Cell
func cell_delete(from: int, to: int) -> void:
	var action_text: String = tr("ACTION_CELL_EDIT_CELL_DELETE").format({
		"count": 1 + to - from
	})
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(cell_remove_multiple_commit.bind(from, to))
	undo_redo.add_do_method(emit_signal.bind("cell_count_changed"))
	undo_redo.add_do_method(cell_remove_try_reload)
	
	# Is this excessive...?
	for cell in 1 + to - from:
		undo_redo.add_undo_method(
			cell_add_commit.bind(from, obj_data.cells[to - cell]))
	
	undo_redo.add_undo_method(emit_signal.bind("cell_count_changed"))
	undo_redo.add_undo_method(cell_remove_try_reload)
	
	status_register_action(action_text)
	undo_redo.commit_action()


# Add Cell
func cell_new(after: bool = false) -> void:
	var new_cell: Cell = Cell.new()
	
	var at: int = cell_index + (after as int)
	
	var action_text: String = tr("ACTION_CELL_EDIT_CELL_NEW").format({
		"index": at
	})
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(cell_add_commit.bind(at, new_cell))
	undo_redo.add_do_method(emit_signal.bind("cell_count_changed"))
	undo_redo.add_do_method(cell_load.bind(at))
		
	undo_redo.add_undo_method(cell_remove_commit.bind(at))
	undo_redo.add_undo_method(emit_signal.bind("cell_count_changed"))
	undo_redo.add_undo_method(cell_remove_try_reload)
	
	status_register_action(action_text)
	undo_redo.commit_action()


func cell_add_commit(at: int, cell: Cell) -> void:
	if at >= obj_data.cells.size():
		obj_data.cells.append(cell)
	else:
		obj_data.cells.insert(at, cell)


func cell_remove_commit(at: int) -> void:
	obj_data.cells.remove_at(at)


func cell_remove_multiple_commit(from: int, to: int) -> void:
	for cell in 1 + to - from:
		obj_data.cells.remove_at(from)


func cell_remove_try_reload() -> void:
	cell_index = clampi(cell_index, 0, obj_data.cells.size() - 1)
	cell_load(cell_index)


# Copy Cell
func cell_copy() -> void:
	cell_clipboard = this_cell.duplicate(true)
	
	# Arrays of custom resources return shallow copies
	var new_box_array: Array[BoxInfo] = []
	for box in cell_clipboard.boxes:
		new_box_array.append(box.duplicate())
	
	cell_clipboard.boxes = new_box_array
	
	Status.set_status(tr("CELL_EDIT_CELL_COPY").format({
		"index": cell_index
	}))


func cell_paste(at: int = 0) -> void:
	if cell_clipboard == null:
		Status.set_status("CELL_EDIT_CELL_PASTE_NOTHING")
		return
	
	var action_text: String = tr("ACTION_CELL_EDIT_CELL_PASTE").format({
		"index": cell_index + clampi(at, 0, 1)
	})
	
	var cell: Cell = cell_clipboard.duplicate(true)
	
	# Arrays of custom resources return shallow copies
	var new_box_array: Array[BoxInfo] = []
	for box in cell.boxes:
		new_box_array.append(box.duplicate())
	
	cell.boxes = new_box_array
	
	undo_redo.create_action(action_text)
	
	match at:
		-1, 1: # Insert
			var new_at: int = cell_index + int(at == 1)
				
			undo_redo.add_do_method(cell_add_commit.bind(new_at, cell))
			undo_redo.add_do_method(emit_signal.bind("cell_count_changed"))
			undo_redo.add_do_method(cell_load.bind(new_at))
			
			undo_redo.add_undo_method(cell_remove_commit.bind(new_at))
			undo_redo.add_undo_method(emit_signal.bind("cell_count_changed"))
			undo_redo.add_undo_method(cell_remove_try_reload)
		
		0: # Replace current
			var old_cell: Cell = this_cell
			
			undo_redo.add_do_method(cell_remove_commit.bind(cell_index))
			undo_redo.add_do_method(cell_add_commit.bind(cell_index, cell))
			undo_redo.add_do_method(emit_signal.bind("cell_count_changed"))
			undo_redo.add_do_method(cell_load.bind(cell_index))
			
			undo_redo.add_undo_method(cell_remove_commit.bind(cell_index))
			undo_redo.add_undo_method(cell_add_commit.bind(cell_index, old_cell))
			undo_redo.add_undo_method(emit_signal.bind("cell_count_changed"))
			undo_redo.add_undo_method(cell_load.bind(cell_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()
#endregion


#region Sprites
func sprite_get(index: int = 0) -> BinSprite:
	return obj_data["sprites"][index]
	
	
func sprite_get_count() -> int:
	return obj_data["sprites"].size()


func on_sprites_imported() -> void:
	cell_load(cell_index)
	
func on_sprite_reindexed(for_session: int, sprite_index: int) -> void:
	if for_session != session_id or this_cell.sprite_index != sprite_index:
		return
	
	cell_load(cell_index)
#endregion


#region Sprite Info
func sprite_get_index() -> int:
	return this_cell.sprite_index
	
	
func sprite_get_position() -> Vector2i:
	return Vector2i(this_cell.sprite_x_offset, this_cell.sprite_y_offset)


func sprite_set_index(new_index: int) -> void:
	var action_text: String = tr("ACTION_CELL_EDIT_SPRITE_INDEX").format({
		"index": cell_index
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	var old_index: int = sprite_get_index()
	
	undo_redo.add_do_property(this_cell, "sprite_index", new_index)
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.add_undo_property(this_cell, "sprite_index", old_index)
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func sprite_set_position(new_position: Vector2i) -> void:
	var action_text: String = tr("ACTION_CELL_EDIT_SPRITE_OFFSET").format({
		"index": cell_index
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	undo_redo.add_do_property(this_cell, "sprite_x_offset", new_position.x)
	undo_redo.add_do_property(this_cell, "sprite_y_offset", new_position.y)
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.add_undo_property(
		this_cell, "sprite_x_offset", this_cell.sprite_x_offset
	)
	undo_redo.add_undo_property(
		this_cell, "sprite_y_offset", this_cell.sprite_y_offset
	)
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func sprite_set_position_x(new_x: int) -> void:
	var action_text: String = tr("ACTION_CELL_EDIT_SPRITE_OFFSET_X").format({
		"index": cell_index
	})
	
	if new_x < -32768 or new_x > 32767:
		return
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	undo_redo.add_do_property(this_cell, "sprite_x_offset", new_x)
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.add_undo_property(
		this_cell, "sprite_x_offset", this_cell.sprite_x_offset)
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func sprite_set_position_y(new_y: int) -> void:
	var action_text: String = tr("ACTION_CELL_EDIT_SPRITE_OFFSET_Y").format({
		"index": cell_index
	})
	
	if new_y < -32768 or new_y > 32767:
		return
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	undo_redo.add_do_property(this_cell, "sprite_y_offset", new_y)
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.add_undo_property(
		this_cell, "sprite_y_offset", this_cell.sprite_y_offset)
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func sprite_info_paste() -> void:
	if Clipboard.sprite_info == null:
		Status.set_status("CELL_EDIT_SPRITE_INFO_PASTE_NOTHING")
		return
	
	var action_text: String = tr("ACTION_CELL_EDIT_SPRITE_INFO_PASTE").format({
		"index": cell_index
	})
	
	undo_redo.create_action(action_text)
	
	# Do
	undo_redo.add_do_property(this_cell, "sprite_index", Clipboard.sprite_index)
	undo_redo.add_do_property(
		this_cell, "sprite_x_offset", Clipboard.sprite_x_offset
	)
	undo_redo.add_do_property(
		this_cell, "sprite_y_offset", Clipboard.sprite_y_offset
	)
	undo_redo.add_do_property(this_cell, "unknown_1", Clipboard.unknown_1)
	undo_redo.add_do_property(this_cell, "unknown_2", Clipboard.unknown_2)
	
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	
	# Undo
	undo_redo.add_undo_property(
		this_cell, "sprite_index", this_cell.sprite_index
	)
	undo_redo.add_undo_property(
		this_cell, "sprite_x_offset", this_cell.sprite_x_offset
	)
	undo_redo.add_undo_property(
		this_cell, "sprite_y_offset", this_cell.sprite_y_offset
	)
	undo_redo.add_undo_property(this_cell, "unknown_1", this_cell.unknown_1)
	undo_redo.add_undo_property(this_cell, "unknown_2", this_cell.unknown_2)
	
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	# Commit
	status_register_action(action_text)
	
	undo_redo.commit_action()
#endregion


#region Boxes
func box_toggle_display(value: bool) -> void:
	display_boxes = value
	box_update_display()


func box_update_display() -> void:
	box_draw_node.visible = display_boxes
	box_type_menu.visible = display_boxes
	box_edit_mode.button_pressed = false
	box_edit_mode.disabled = !display_boxes


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
	boxes_selected.clear()
	box_deselected_all.emit()


func box_set_editing(enabled: bool) -> void:
	box_edits_allowed = enabled
	box_editing_toggled.emit(enabled)
	box_deselect_all()


func box_set_draw_mode(enabled: bool) -> void:
	box_drawing_mode = enabled
	box_drawing_mode_changed.emit(enabled)


func box_is_type_visible(type: int) -> bool:
	return box_display_types[clampi(type, 0, box_type_ids.size() - 1)]


func box_set_type_visible(type: int, enabled: bool) -> void:
	for index in box_type_ids[clampi(type, 0, box_type_ids.size() - 1)]:
		box_display_types[index] = enabled


func box_append(box: BoxInfo) -> void:
	var action_text: String = tr("ACTION_CELL_EDIT_BOX_NEW").format({
		"index": cell_index
	})
	
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_do_method(box_append_commit.bind(this_cell, box))
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.add_undo_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_undo_method(box_delete_commit.bind(this_cell, box))
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func box_delete() -> void:
	if boxes_selected.size() == 0:
		Status.set_status("CELL_EDIT_BOX_DELETE_NOTHING")
		return
	
	var action_text: String
	
	if boxes_selected.size() > 1:
		action_text = tr("ACTION_CELL_EDIT_BOX_DELETE_MULTI").format({
			"index": cell_index
		})
		undo_redo.create_action(action_text + " (%s)" %
			Engine.get_physics_frames(), UndoRedo.MERGE_ALL)
	else:
		action_text = tr("ACTION_CELL_EDIT_BOX_DELETE").format({
			"index": cell_index
		})
		undo_redo.create_action(action_text)
	
	for box_index in boxes_selected:
		var deleted_box: BoxInfo = box_get(box_index)
		
		undo_redo.add_do_method(box_delete_commit.bind(this_cell, deleted_box))
		undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
		
		undo_redo.add_undo_method(box_append_commit.bind(this_cell, deleted_box, box_index))
		undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	undo_redo.add_do_method(box_deselect_all)
	undo_redo.add_undo_method(box_set_selection.bind(boxes_selected))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func box_append_commit(cell: Cell, box: BoxInfo, index: int = -1) -> void:
	if index < 0:
		cell.boxes.append(box)
	else:
		cell.boxes.insert(index, box)


func box_delete_commit(cell: Cell, box: BoxInfo) -> void:
	cell.boxes.remove_at(cell.boxes.find(box))


func box_paste(overwrite: bool = false) -> void:
	if Clipboard.box_data.size() == 0:
		Status.set_status("STATUS_CELL_EDIT_BOX_PASTE_NOTHING")
		return
	
	var action_text: String = tr("ACTION_CELL_EDIT_BOX_PASTE").format({
		"index": cell_index
	})
	
	if overwrite:
		action_text = action_text + " " + "ACTION_CELL_EDIT_BOX_PASTE_OVERWRITE"
	
	undo_redo.create_action(action_text)
	
	if overwrite:
		for box in this_cell.boxes:
			undo_redo.add_do_method(box_delete_commit.bind(this_cell, box))
			undo_redo.add_undo_method(box_append_commit.bind(this_cell, box))
	
	for box in Clipboard.get_box_data():
		undo_redo.add_do_method(box_append_commit.bind(this_cell, box))
		undo_redo.add_undo_method(box_delete_commit.bind(this_cell, box))
		
	undo_redo.add_do_method(emit_signal.bind("cell_updated", this_cell))
	undo_redo.add_undo_method(emit_signal.bind("cell_updated", this_cell))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func box_set_type(new_type: int) -> void:
	if boxes_selected.size() == 0:
		return
	
	var action_text: String
	
	if boxes_selected.size() > 1:
		action_text = tr("ACTION_CELL_EDIT_BOX_TYPE_MULTI").format({
			"index": cell_index
		})
			
		undo_redo.create_action(
			action_text + " (%s)" % Engine.get_physics_frames(),
			UndoRedo.MERGE_ALL)

	else:
		action_text = tr("ACTION_CELL_EDIT_BOX_TYPE").format({
			"index": cell_index
		})
		undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	for box in boxes_selected:
		var current_box: BoxInfo = this_cell.boxes[box]
		
		undo_redo.add_do_property(current_box, "box_type", new_type)
		undo_redo.add_do_method(cell_ensure_selected.bind(cell_index))
		undo_redo.add_do_method(emit_signal.bind("box_updated", current_box))
			
		undo_redo.add_undo_property(
			current_box, "box_type", current_box.box_type
		)
		undo_redo.add_undo_method(cell_ensure_selected.bind(cell_index))
		undo_redo.add_undo_method(emit_signal.bind("box_updated", current_box))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func box_multi_drag(index: int, motion: Vector2) -> void:
	box_multi_dragged.emit(index, motion)


func box_multi_drag_stop(index: int) -> void:
	box_multi_drag_stopped.emit(index)


func box_set_offset_x(new_value: int) -> void:
	if boxes_selected.size() < 1:
		return
	
	var action_text: String = tr("ACTION_CELL_EDIT_BOX_OFFSET_X").format({
		"index": cell_index
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	undo_redo.add_do_property(this_box, "x_offset", new_value)
	undo_redo.add_do_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "x_offset", this_box.x_offset)
	undo_redo.add_undo_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func box_set_offset_y(new_value: int) -> void:
	if boxes_selected.size() < 1:
		return
	
	var action_text: String = tr("ACTION_CELL_EDIT_BOX_OFFSET_Y").format({
		"index": cell_index
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	undo_redo.add_do_property(this_box, "y_offset", new_value)
	undo_redo.add_do_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "y_offset", this_box.y_offset)
	undo_redo.add_undo_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func box_set_width(new_value: int) -> void:
	if boxes_selected.size() < 1:
		return
	
	var action_text: String = tr("ACTION_CELL_EDIT_BOX_WIDTH").format({
		"index": cell_index
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	undo_redo.add_do_property(this_box, "width", new_value)
	undo_redo.add_do_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "width", this_box.width)
	undo_redo.add_undo_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func box_set_height(new_value: int) -> void:
	if boxes_selected.size() < 1:
		return
	
	var action_text: String = tr("ACTION_CELL_EDIT_BOX_HEIGHT").format({
		"index": cell_index
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	undo_redo.add_do_property(this_box, "height", new_value)
	undo_redo.add_do_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "height", this_box.height)
	undo_redo.add_undo_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	status_register_action(action_text)
	undo_redo.commit_action()


# Seems to work fine...?
func box_set_rect_for(index: int, rect: Rect2i) -> void:
	var action_text: String
	
	if boxes_selected.size() > 1:
		action_text = tr("ACTION_CELL_EDIT_BOX_MODIFY_MULTI").format({
			"index": cell_index
		})
		undo_redo.create_action(
			action_text + " (%s)" % Engine.get_physics_frames(),
			UndoRedo.MERGE_ALL)
	else:
		action_text = tr("ACTION_CELL_EDIT_BOX_MODIFY").format({
			"index": cell_index,
			"box": index
		})
		undo_redo.create_action(action_text)
	
	var this_box: BoxInfo = box_get(index)
	
	undo_redo.add_do_property(this_box, "x_offset", rect.position.x)
	undo_redo.add_do_property(this_box, "y_offset", rect.position.y)
	undo_redo.add_do_property(this_box, "width", rect.size.x)
	undo_redo.add_do_property(this_box, "height", rect.size.y)
	undo_redo.add_do_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "x_offset", this_box.x_offset)
	undo_redo.add_undo_property(this_box, "y_offset", this_box.y_offset)
	undo_redo.add_undo_property(this_box, "width", this_box.width)
	undo_redo.add_undo_property(this_box, "height", this_box.height)
	undo_redo.add_undo_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func box_set_crop_offset_x(new_value: int) -> void:
	if boxes_selected.size() < 1:
		return
	
	var action_text: String = tr("ACTION_CELL_EDIT_REGION_OFFSET_X").format({
		"index": cell_index
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	undo_redo.add_do_property(this_box, "crop_x_offset", new_value)
	undo_redo.add_do_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "crop_x_offset", this_box.crop_x_offset)
	undo_redo.add_undo_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func box_set_crop_offset_y(new_value: int) -> void:
	if boxes_selected.size() < 1:
		return
	
	var action_text: String = tr("ACTION_CELL_EDIT_REGION_OFFSET_Y").format({
		"index": cell_index
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	var this_box: BoxInfo = box_get(boxes_selected[0])
	
	undo_redo.add_do_property(this_box, "crop_y_offset", new_value)
	undo_redo.add_do_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_do_method(emit_signal.bind("box_updated", this_box))
	
	undo_redo.add_undo_property(this_box, "crop_y_offset", this_box.crop_y_offset)
	undo_redo.add_undo_method(cell_ensure_selected.bind(cell_index))
	undo_redo.add_undo_method(emit_signal.bind("box_updated", this_box))
	
	status_register_action(action_text)
	undo_redo.commit_action()
#endregion


#region Snapshots
func save_snapshot(cell_number: int) -> void:
	var cell: Cell = obj_data.cells[cell_number]
	
	# Generate filename, path
	var file: String = \
		SessionData.get_session(session_id)["path"].get_file()
	var date: Dictionary = Time.get_datetime_dict_from_system()
	var file_name: String = "%s_CELL-%04d" % [file, cell_number]
	
	file_name += "_%04d-%02d-%02d_%02d-%02d-%02d" % [
		date["year"], date["month"], date["day"],
		date["hour"], date["minute"], date["second"]
	]
	
	var path: String = OS.get_executable_path().get_base_dir()\
		 + "/snapshots/"
	
	# Create path for first time save
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	
	# Snapshot data...
	var pal: PackedByteArray
	
	# Global/local pal
	if obj_data.has("palettes"):
		pal = provider.palette.palette
	else:
		pal = obj_data.sprites[cell.sprite_index].palette
	
	# Origin cross
	var origin: PackedByteArray = []
	
	var types_to_draw: Array[bool] = []
	types_to_draw.resize(box_display_types.size())
	
	if display_boxes:
		types_to_draw = box_display_types
	
	if Settings.cell_draw_origin:
		var this_tex: Texture2D = origin_textures[Settings.cell_origin_type]
		# Tex width/height
		origin.append(this_tex.get_width())
		# Pixels
		origin.append_array(this_tex.get_image().get_data())
	
	
	# Options 0 and 2: PNG
	if Settings.cell_snapshot_format % 2 == 0:
		# Save
		cell.save_snapshot_png(
			# Sprite
			obj_data.sprites[cell.sprite_index], pal, false,
			# Boxes
			types_to_draw,
			Settings.box_colors,
			Settings.box_thickness,
			# Origin cross
			origin,
			# Save path
			path + file_name + ".png"
		)
	
	# Options 1 and 2: PSD
	if Settings.cell_snapshot_format > 0:
		# Save
		cell.save_snapshot_psd(
			# Sprite
			obj_data.sprites[cell.sprite_index], pal, false,
			# Boxes
			types_to_draw,
			Settings.box_colors,
			Settings.box_thickness,
			# Origin cross
			origin,
			# Save path
			path + file_name + ".psd"
		)


func snapshot_range(from: int, to: int) -> void:
	WorkerThreadPool.add_task(snapshot_range_thread.bind(from, to))


func snapshot_range_thread(from: int, to: int) -> void:
	from = min(from, obj_data.cells.size() - 1)
	to = max(to, 0)
	
	call_deferred("emit_signal", "cell_snapshots_start", to - from + 1)
	
	for index in range(from, to + 1):
		save_snapshot(index)
		call_deferred("emit_signal", "cell_snapshot_taken")
	
	call_deferred("emit_signal", "cell_snapshots_done")
#endregion
