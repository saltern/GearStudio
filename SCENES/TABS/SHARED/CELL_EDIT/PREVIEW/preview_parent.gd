extends PanelContainer

@export var visualizer: Node2D
@export var box_parent: Control

var panning: bool = false
var tentative: bool = false
var sprite_drag: bool = false

var accum: Vector2

@onready var cell_edit: CellEdit = get_owner()


func _process(_delta: float) -> void:
	queue_redraw()


func _gui_input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseMotion:
		if sprite_drag:
			var mov_scale: float = get_node("visualizer").scale.x
			var scaled_relative: Vector2 = input_event.relative / mov_scale
			accum += scaled_relative
			var accum_floor := Vector2(floor(accum.x), floor(accum.y))
			
			cell_edit.sprite_set_position(
				cell_edit.this_cell.sprite_info.position +
				(accum_floor as Vector2i))
			
			accum -= accum_floor
	
		elif panning:
			get_child(0).position += input_event.relative
		
		box_parent.drag(input_event.position - visualizer.position)
			
	if not input_event is InputEventMouseButton:
		return
	
	var event := input_event as InputEventMouseButton
	
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
				if cell_edit.box_drawing_mode:
					box_parent.start_drawing(
						event.position - visualizer.position)
				
				elif event.alt_pressed:
					sprite_drag = true
				
				else:
					tentative = true
			
			else:
				if sprite_drag:
					sprite_drag = false
					accum = Vector2.ZERO
				
				elif tentative:
					cell_edit.box_deselect_all()
					tentative = false
				
				box_parent.stop_drawing(
					event.position - visualizer.position, true)
