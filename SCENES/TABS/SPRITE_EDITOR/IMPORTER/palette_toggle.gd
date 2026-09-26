extends CheckButton

@export var dialog: SpriteImportDialog


func _ready() -> void:
	dialog.session_set.connect(on_session_set.unbind(2))


func _toggled(toggled_on: bool) -> void:
	dialog.set_palette_enabled(toggled_on)


func on_session_set() -> void:
	_toggled(button_pressed)
