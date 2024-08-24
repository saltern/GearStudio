extends SpinBox


func _ready() -> void:
	value_changed.connect(change_palette)
	
	change_palette(0)


func change_palette(new_palette: int) -> void:
	SharedData.get_palette(new_palette)
