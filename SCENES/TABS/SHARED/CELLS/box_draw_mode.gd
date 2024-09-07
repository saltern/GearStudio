extends Button


func _ready() -> void:
	var obj_state := SessionData.object_state_get(get_owner().get_parent().name)
	obj_state.box_editing_toggled.connect(on_box_editing_toggled)
	
	toggled.connect(on_draw_mode_toggled)
	
	disabled = true


func on_box_editing_toggled(enabled: bool) -> void:
	if button_pressed:
		button_pressed = false
		SessionData.box_set_draw_mode(false)
	
	disabled = !enabled


func on_draw_mode_toggled(enabled: bool) -> void:
	if enabled:
		SessionData.box_deselect_all()
	
	SessionData.box_set_draw_mode(enabled)
