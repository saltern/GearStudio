extends Button


func _ready() -> void:
	var obj_state: ObjectEditState = SessionData.object_state_get(
		get_owner().get_parent().name)
	
	obj_state.box_editing_toggled.connect(on_box_editing_toggled)
	
	pressed.connect(on_delete_pressed)
	disabled = true


func on_box_editing_toggled(enabled: bool) -> void:
	disabled = !enabled


func on_delete_pressed() -> void:
	SessionData.box_delete()
