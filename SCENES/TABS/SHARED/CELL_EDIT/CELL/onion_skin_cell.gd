extends SteppingSpinBox

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	cell_edit.cell_count_changed.connect(update_range)
	update_range()
	
	min_value = -1
	value = -1


func update_range() -> void:
	max_value = cell_edit.cell_get_count() - 1
