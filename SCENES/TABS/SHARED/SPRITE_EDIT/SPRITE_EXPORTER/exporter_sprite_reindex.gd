extends CheckButton


func _ready() -> void:
	visibility_changed.connect(update)


func _toggled(toggled_on: bool) -> void:
	SpriteExport.set_sprite_reindex(toggled_on)


func update() -> void:
	if visible:
		_toggled(button_pressed)
