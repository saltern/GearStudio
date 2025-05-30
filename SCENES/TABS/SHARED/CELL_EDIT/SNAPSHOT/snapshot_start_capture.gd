extends Button

@export var from: SteppingSpinBox
@export var to: SteppingSpinBox

@onready var cell_edit: CellEdit = owner


func _pressed() -> void:
	cell_edit.snapshot_range(from.value as int, to.value as int)
