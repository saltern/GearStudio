extends SpinBox


func _ready() -> void:
	value_changed.connect(SessionData.sprite_set_position_y)
