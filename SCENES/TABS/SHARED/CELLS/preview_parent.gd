extends PanelContainer

@export var visualizer: Node2D
@export var box_parent: Control

var panning: bool = false
var tentative: bool = false


func _process(_delta: float) -> void:
	queue_redraw()


func _gui_input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion:
		if panning:
			get_child(0).position += event.relative
		
		box_parent.drag(event.position - visualizer.position)
			
	if not event is InputEventMouseButton:
		return
	
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			if event.pressed && event.is_command_or_control_pressed():
				get_child(0).zoom_in()
				get_viewport().set_input_as_handled()
	
		MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed && event.is_command_or_control_pressed():
				get_child(0).zoom_out()
				get_viewport().set_input_as_handled()
	
		MOUSE_BUTTON_RIGHT:
			if event.pressed:
				panning = true
			else:
				panning = false
	
		MOUSE_BUTTON_LEFT:
			if event.pressed:
				if SessionData.box_get_draw_mode():
					box_parent.start_drawing(
						event.position - visualizer.position)
				else:
					tentative = true
			
			else:
				if tentative:
					SessionData.box_deselect_all()
					tentative = false
				
				box_parent.stop_drawing(
					event.position - visualizer.position, true)
