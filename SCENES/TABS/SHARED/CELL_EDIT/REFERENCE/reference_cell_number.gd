extends SteppingSpinBox

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	min_value = -1
	on_ref_data_cleared()
	
	cell_edit.ref_data_set.connect(on_ref_data_set)
	cell_edit.ref_data_cleared.connect(on_ref_data_cleared)
	cell_edit.ref_session_cleared.connect(on_ref_data_cleared)
	value_changed.connect(update)


func on_ref_data_set(data: Dictionary) -> void:
	if not data.has("cells"):
		on_ref_data_cleared()
		return
	
	max_value = data.cells.size() - 1
	editable = true


func on_ref_data_cleared() -> void:
	max_value = -1
	editable = false


func update(new_value: float) -> void:
	cell_edit.reference_cell_set(int(new_value))
