extends SteppingSpinBox

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	min_value = -1
	max_value = cell_edit.cell_get_count() - 1
	value = -1
