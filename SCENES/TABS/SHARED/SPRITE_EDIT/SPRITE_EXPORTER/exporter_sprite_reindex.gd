extends CheckButton


func _toggled(toggled_on: bool) -> void:
	SpriteExport.set_sprite_reindex(toggled_on)
