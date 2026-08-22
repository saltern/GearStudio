class_name ReferenceHandler extends Resource

signal ref_session_set
signal ref_session_cleared
signal ref_data_set
signal ref_data_cleared
signal ref_cell_updated
signal ref_cell_cleared
signal ref_cell_index_set
signal ref_action_index_set

var session: Session
var obj_data: BinScriptable
var cell_index: int = -1

var action_index: int = -1
var instruction_index: int = -1


func cell_load(index: int) -> void:
	if obj_data == null or obj_data.get_cell_count() <= index:
		ref_cell_cleared.emit()
		return
	
	if cell_index > -1:
		return
	
	ref_cell_updated.emit(obj_data.get_cell(index))


func cell_get_count() -> int:
	return obj_data.cells.size()


func cell_get(index: int) -> BinCell:
	if obj_data.cells.size() > index:
		return obj_data.cells.cells[index]
	else:
		return BinCell.new()


func reference_set_session(session_index: int) -> void:
	session = SessionData.get_session(session_index)
	ref_session_set.emit(session)


func reference_set_object(object: int) -> void:
	if session.size() <= object:
		obj_data = null
		return
	
	obj_data = session.data[object]
	ref_data_set.emit(obj_data)


func reference_clear_session() -> void:
	session = null
	obj_data = null
	ref_session_cleared.emit()


func reference_clear_object() -> void:
	obj_data = null
	ref_data_cleared.emit()


func reference_cell_get(index: int) -> BinCell:
	if obj_data == null:
		return BinCell.new()
	
	if not obj_data.cells.size() > index:
		return BinCell.new()
	
	return obj_data.get_cell(index)


func reference_cell_set(index: int) -> void:
	cell_index = index
	ref_cell_index_set.emit(cell_index)


func reference_action_set(index: int) -> void:
	action_index = index
	ref_action_index_set.emit(action_index)


func script_has_action(index: int) -> bool:
	if obj_data.is_empty() or obj_data.scripts.actions.size() <= index:
		return false
	
	return true


func script_get_action(index: int) -> Action:
	return obj_data.scripts.actions[index]
