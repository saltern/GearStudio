extends CheckButton


func _ready() -> void:
	toggled.connect(on_zero_naming_toggled)


func on_zero_naming_toggled(enabled: bool) -> void:
	SpriteExport.set_name_from_zero(enabled)
