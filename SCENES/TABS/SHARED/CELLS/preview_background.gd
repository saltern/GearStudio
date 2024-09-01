extends TextureRect

var panning: bool = false
var tentative: bool = false


func _gui_input(event) -> void:
	if event is InputEventMouseMotion:
		if panning:
			get_parent().position += event.relative
	
	if not event is InputEventMouseButton:
		return
	
	if event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			panning = true
		else:
			panning = false
	
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	if event.pressed:
		tentative = true
	
	else:
		if tentative:
			SessionData.box_deselect_all()
			
		tentative = false
