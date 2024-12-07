extends SpinBox

@onready var palette_edit: PaletteEdit = get_owner()
@onready var provider: PaletteProvider = palette_edit.provider


func _ready() -> void:
	max_value = palette_edit.palette_get_count() - 1
	
	value_changed.connect(SessionData.set_palette)
	SessionData.palette_changed.connect(palette_set_session)


func palette_set_session(for_session: int, index: int) -> void:
	if for_session != palette_edit.session_id:
		return
	
	set_value_no_signal.call_deferred(index)
	provider.palette_load(index)
