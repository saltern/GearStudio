class_name SteppingSpinBox extends SpinBox


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
	
	if not get_line_edit().has_focus():
		return
	
	if not event.pressed:
		return
	
	var key: InputEventKey = event
	
	match key.keycode:
		KEY_UP:
			if key.is_command_or_control_pressed():
				value += 9
			
			value += 1
		
		KEY_DOWN:
			if key.is_command_or_control_pressed():
				value -= 9
			
			value -= 1