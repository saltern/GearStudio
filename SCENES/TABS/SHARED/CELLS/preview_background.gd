extends TextureRect

var tentative: bool = false


func _gui_input(event) -> void:
	if not event is InputEventMouseButton:
		return
	
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	if event.pressed:
		tentative = true
	
	else:
		if tentative:
			SessionData.box_deselect_all()
			
		tentative = false
