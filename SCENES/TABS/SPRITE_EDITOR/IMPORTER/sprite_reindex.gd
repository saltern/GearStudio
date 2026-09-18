extends CheckButton

@export var dialog: SpriteImportDialog


func _toggled(toggled_on: bool) -> void:
	dialog.set_sprite_reindex(toggled_on)
