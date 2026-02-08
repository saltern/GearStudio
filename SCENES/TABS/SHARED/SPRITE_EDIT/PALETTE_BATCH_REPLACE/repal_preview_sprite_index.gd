extends SteppingSpinBox

@export var range_start: SteppingSpinBox
@export var range_end: SteppingSpinBox


func _ready() -> void:
	range_start.value_changed.connect(on_range_changed.unbind(1))
	range_end.value_changed.connect(on_range_changed.unbind(1))
	on_range_changed()


func on_range_changed() -> void:
	min_value = range_start.value
	max_value = range_end.value
