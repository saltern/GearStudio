extends Label

@export var range_start: SpinBox
@export var range_end: SpinBox

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	range_start.value_changed.connect(update.unbind(1))
	range_end.value_changed.connect(update.unbind(1))
	visibility_changed.connect(update)


func update() -> void:
	var delete_count: int = 1 + range_end.value - range_start.value
	
	if delete_count >= cell_edit.cell_get_count():
		text = "CELL_EDIT_DELETE_CANNOT_DELETE"
	else:
		text = tr("CELL_EDIT_DELETE_WILL_DELETE").format({
			"count": delete_count
		})
