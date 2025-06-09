extends SteppingSpinBox

@onready var script_edit: ScriptEdit = get_owner()


func _ready() -> void:
	if script_edit.obj_data.has("palettes"):
		value_changed.connect(SessionData.set_palette)
		SessionData.palette_changed.connect(external_set_palette)
	else:
		value_changed.connect(script_edit.palette_set_index)
	
	max_value = \
		SessionData.session_get_palettes(script_edit.session_id).size() - 1


func external_set_palette(for_session: int, index: int) -> void:
	if for_session != script_edit.session_id:
		return
	
	set_value_no_signal.call_deferred(index)
