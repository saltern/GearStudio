extends Label

@export var range_start: SteppingSpinBox
@export var range_end: SteppingSpinBox


func _ready() -> void:
	range_start.value_changed.connect(range_changed.unbind(1))
	range_end.value_changed.connect(range_changed.unbind(1))
	range_changed()


func range_changed() -> void:
	var new_count: int = range_end.value - range_start.value + 1
	text = tr("SPRITE_EDIT_BATCH_REPAL_RANGE_PROCESS_COUNT").format({
		"count": new_count
	})
