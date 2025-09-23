extends CheckButton


func _toggled(toggled_on: bool) -> void:
	SpriteExport.set_name_zero_pad(toggled_on)
