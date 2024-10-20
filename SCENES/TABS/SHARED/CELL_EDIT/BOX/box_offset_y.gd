extends SteppingSpinBox

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	value_changed.connect(cell_edit.box_set_offset_y)
	
	cell_edit.box_editing_toggled.connect(on_editing_toggled)
	cell_edit.cell_updated.connect(on_cell_update)
	cell_edit.box_updated.connect(on_box_update)
	cell_edit.box_selected.connect(on_box_update)
	cell_edit.box_deselected_all.connect(reset)


func reset() -> void:
	call_deferred("set_value_no_signal", 0)


func on_cell_update(_cell: Cell) -> void:
	reset()


func on_box_update(box: BoxInfo) -> void:
	if cell_edit.boxes_selected.size() > 1:
		reset()
		editable = false
	else:
		call_deferred("set_value_no_signal", box.rect.position.y)
		editable = true


func on_editing_toggled(enabled: bool) -> void:
	editable = enabled
