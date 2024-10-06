class_name ZoomablePreview extends PanelContainer

@export var visualizer: Node2D

var panning: bool = false
var accum: Vector2


func _process(_delta: float) -> void:
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not handle_zoom_pan(event):
			mouse_button(event as InputEventMouseButton)
	
	elif event is InputEventMouseMotion:
		if not handle_pan_drag(event):
			mouse_motion(event as InputEventMouseMotion)


func handle_zoom_pan(event: InputEventMouseButton) -> bool:
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			if event.pressed && event.is_command_or_control_pressed():
				visualizer.zoom_in()
				get_viewport().set_input_as_handled()
				return true
	
		MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed && event.is_command_or_control_pressed():
				visualizer.zoom_out()
				get_viewport().set_input_as_handled()
				return true
		
		MOUSE_BUTTON_RIGHT:
			if event.pressed:
				panning = true
				return true
			else:
				panning = false
				return true
	
	return false


func handle_pan_drag(event: InputEventMouseMotion) -> bool:
	if panning:
		visualizer.position += event.relative
		return true
	
	return false


func mouse_button(event: InputEventMouseButton) -> void:
	pass


func mouse_motion(event: InputEventMouseMotion) -> void:
	pass
