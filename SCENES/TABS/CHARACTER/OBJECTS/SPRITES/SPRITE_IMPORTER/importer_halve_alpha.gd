extends CheckButton


func _ready() -> void:
	toggled.connect(update)
	visibility_changed.connect(on_display)


func on_display() -> void:
	if visible:
		update(button_pressed)


func update(enabled: bool) -> void:
	SpriteImport.set_halve_alpha(enabled)
