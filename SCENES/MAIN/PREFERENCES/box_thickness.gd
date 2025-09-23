extends SpinBox


func _ready() -> void:
	set_value_no_signal(Settings.box_thickness)
	value_changed.connect(update)


func update(new_value: int) -> void:
	Settings.set_box_thickness(new_value)
