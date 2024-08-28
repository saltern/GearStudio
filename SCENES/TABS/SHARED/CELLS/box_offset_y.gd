extends SpinBox


func _ready() -> void:
	value_changed.connect(SessionData.box_set_offset_y)
