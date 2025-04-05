extends SpinBox


func _ready() -> void:
	set_value_no_signal(Settings.misc_max_undo)
	value_changed.connect(update)


func update(new_value: int) -> void:
	Settings.misc_max_undo = new_value
	Settings.max_undo_changed.emit()
