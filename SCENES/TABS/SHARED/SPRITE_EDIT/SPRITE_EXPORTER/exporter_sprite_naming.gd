extends CheckButton


func _ready() -> void:
	visibility_changed.connect(update)


func _toggled(toggled_on: bool) -> void:
	SpriteExport.set_name_from_zero(toggled_on)


func update() -> void:
	if visible:
		_toggled(button_pressed)
