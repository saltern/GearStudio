extends TextureRect

signal preview_background_clicked

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
			preview_background_clicked.emit()
			#SharedData.deselect_boxes()
			
		tentative = false
