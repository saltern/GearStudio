extends PanelContainer

var panning: bool = false
var tentative: bool = false


func _gui_input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion:
		if panning:
			get_child(0).position += event.relative
	
	if not event is InputEventMouseButton:
		return
	
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			if event.pressed && event.is_command_or_control_pressed():
				get_child(0).zoom_in()
	
		MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed && event.is_command_or_control_pressed():
				get_child(0).zoom_out()
	
		MOUSE_BUTTON_RIGHT:
			if event.pressed:
				panning = true
			else:
				panning = false
	
		MOUSE_BUTTON_LEFT:
			if event.pressed:
				tentative = true
			
			elif tentative:
				SessionData.box_deselect_all()
				tentative = false
