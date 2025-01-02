extends SteppingSpinBox

enum Type {
	UNKNOWN_1,
	UNKNOWN_2,
}

@export var type: Type

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	cell_edit.cell_updated.connect(update)


func update(cell: Cell) -> void:
	match type:
		Type.UNKNOWN_1:
			set_value_no_signal.bind(cell.unknown_1).call_deferred()
		Type.UNKNOWN_2:
			set_value_no_signal.bind(cell.unknown_2).call_deferred()
