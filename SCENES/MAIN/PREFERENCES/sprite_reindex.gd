extends CheckButton


func _ready() -> void:
	button_pressed = Settings.sprite_reindex
	toggled.connect(update)


func update(enabled: bool) -> void:
	Settings.sprite_reindex = enabled
