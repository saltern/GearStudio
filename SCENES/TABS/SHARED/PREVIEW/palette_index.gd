extends SteppingSpinBox

@onready var provider: Node = get_owner()


func _ready() -> void:
	if not provider.obj_data.has("palettes"):
		get_parent().hide()
		return
	
	max_value = provider.obj_data["palettes"].size() - 1
	
	value_changed.connect(SessionData.set_palette)
	SessionData.palette_changed.connect(external_set_palette)


func external_set_palette(for_session: int, index: int) -> void:
	if for_session != provider.session_id:
		return
	
	set_value_no_signal.call_deferred(index)
