extends CellSpriteDisplay

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	cell_edit.ref_data_set.connect(on_ref_data_set)
	cell_edit.ref_data_cleared.connect(unload_sprite)
	cell_edit.ref_cell_updated.connect(pre_load_cell)
	SessionData.palette_changed.connect(pre_palette_changed)


func on_ref_data_set(data: Dictionary) -> void:
	obj_data = data
	var cell: Cell = cell_edit.reference_cell_get(cell_edit.cell_index)
	pre_load_cell(cell)


func pre_load_cell(cell: Cell) -> void:
	if obj_data.is_empty():
		return
	
	load_cell(cell)


func pre_palette_changed(for_session: int, index: int) -> void:
	if obj_data.is_empty():
		return
	
	if obj_data.has("palettes"):
		palette_set_session(for_session, index)
	else:
		palette_set_session_sprite(for_session, index)


func palette_set_session(for_session: int, index: int) -> void:
	if for_session != cell_edit.session_id:
		return
	
	if obj_data.is_empty():
		return
	
	load_palette(index)


func palette_set_session_sprite(for_session: int, _index: int) -> void:
	if for_session != cell_edit.session_id:
		return
	
	if obj_data.is_empty():
		return
	
	reload_palette()
