extends CheckButton

@export var dialog: SpriteImportDialog


func _ready() -> void:
	dialog.session_set.connect(on_session_set.unbind(2))


func _toggled(toggled_on: bool) -> void:
	dialog.set_sprite_as_rgb(toggled_on)


func on_session_set() -> void:
	if !dialog.has_palettes():
		button_pressed = false
		hide()
	else:
		show()
