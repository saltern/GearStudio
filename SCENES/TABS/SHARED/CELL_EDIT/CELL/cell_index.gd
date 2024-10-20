extends SteppingSpinBox

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:	
	value_changed.connect(cell_edit.cell_load)
	cell_edit.cell_updated.connect(update)
	cell_edit.cell_count_changed.connect(update_range)
	update_range()


func update(_cell: Cell) -> void:
	call_deferred("set_value_no_signal", cell_edit.cell_get_index())


func update_range() -> void:
	max_value = cell_edit.cell_get_count() - 1
