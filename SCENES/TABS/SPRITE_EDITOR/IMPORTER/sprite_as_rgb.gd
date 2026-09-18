extends CheckButton

@export var dialog: SpriteImportDialog


func _toggled(toggled_on: bool) -> void:
	dialog.set_sprite_as_rgb(toggled_on)
