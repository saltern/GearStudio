extends Label

@export var range_start: SpinBox
@export var range_end: SpinBox

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	range_start.value_changed.connect(update.unbind(1))
	range_end.value_changed.connect(update.unbind(1))
	visibility_changed.connect(update)


func update() -> void:
	var snap_count: int = 1 + range_end.value - range_start.value
	
	text = tr("CELL_EDIT_SNAPSHOTS_WILL_SAVE").format({
		"count": snap_count
	})
