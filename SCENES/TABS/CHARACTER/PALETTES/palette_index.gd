extends SpinBox


func _ready() -> void:
	var pal_state: PaletteEditState = SessionData.palette_state_get(
		get_owner().get_parent().get_index())
	
	pal_state.changed_palette.connect(on_palette_load)
	value_changed.connect(pal_state.load_palette)


func on_palette_load(new_palette: int) -> void:
	call_deferred("set_value_no_signal", new_palette)
