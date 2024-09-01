extends ColorPickerButton


func _ready() -> void:
	color_changed.connect(update)


func update(new_color: Color) -> void:
	pass
