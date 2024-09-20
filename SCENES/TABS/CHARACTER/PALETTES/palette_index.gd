extends SpinBox

@onready var palette_edit: PaletteEdit = get_owner()

var provider: PaletteProvider


func _ready() -> void:
	provider = get_owner().get_provider()
	
	#palette_edit.palette_updated.connect(on_palette_load)
	value_changed.connect(provider.palette_load)


#func on_palette_load(new_palette: int) -> void:
	#call_deferred("set_value_no_signal", new_palette)
