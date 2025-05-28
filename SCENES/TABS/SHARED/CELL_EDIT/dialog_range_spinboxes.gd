extends SteppingSpinBox

@export var lower_limit: SpinBox

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	cell_edit.cell_count_changed.connect(update_range)
	
	if lower_limit:
		lower_limit.value_changed.connect(update_range.unbind(1))
	
	update_range()


func update_range() -> void:
	if lower_limit:
		min_value = lower_limit.value
	
	max_value = cell_edit.cell_get_count() - 1
