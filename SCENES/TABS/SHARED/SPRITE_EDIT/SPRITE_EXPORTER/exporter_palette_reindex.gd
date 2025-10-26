extends CheckButton


func _toggled(toggled_on: bool) -> void:
	SpriteExport.set_palette_reindex(toggled_on)
