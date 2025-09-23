extends CheckButton


func _ready() -> void:
	button_pressed = Settings.misc_allow_reopen
	toggled.connect(update)


func update(enabled: bool) -> void:
	Settings.set_allow_reopen(enabled)
