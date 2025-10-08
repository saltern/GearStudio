extends CheckButton


func _ready() -> void:
	button_pressed = Settings.general_reindex_mode


func _toggled(toggled_on: bool) -> void:
	Settings.set_general_reindex_mode(toggled_on)
