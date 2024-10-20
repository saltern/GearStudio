extends SteppingSpinBox

@export var sprite_range_start: SpinBox
@export var sprite_range_end: SpinBox


func _ready() -> void:
	max_value = 0

	sprite_range_start.value_changed.connect(update_range_start)
	sprite_range_end.value_changed.connect(update_range_end)


func update_range_start(new_value: int) -> void:
	min_value = new_value


func update_range_end(new_value: int) -> void:
	max_value = new_value
