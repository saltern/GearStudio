extends SteppingSpinBox

@export var from_cell: SteppingSpinBox
@export var to_cell: SteppingSpinBox


func _ready() -> void:
	from_cell.value_changed.connect(update.unbind(1))
	to_cell.value_changed.connect(update.unbind(1))
	update()


func update() -> void:
	min_value = from_cell.value
	max_value = to_cell.value
