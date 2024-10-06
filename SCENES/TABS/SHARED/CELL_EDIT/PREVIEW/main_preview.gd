extends ZoomablePreview

@export var box_parent: Control

var sprite_drag: bool = false
var tentative: bool = false

@onready var cell_edit: CellEdit = get_owner()


func mouse_button(event: InputEventMouseButton) -> void:
	match event.button_index:
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


func mouse_motion(event: InputEventMouseMotion) -> void:
	if sprite_drag:
		var mov_scale: float = visualizer.scale.x
		var scaled_relative: Vector2 = event.relative / mov_scale
		accum += scaled_relative
		var accum_floor := Vector2(floor(accum.x), floor(accum.y))
		
		cell_edit.sprite_set_position(
			cell_edit.this_cell.sprite_info.position +
			(accum_floor as Vector2i))
		
		accum -= accum_floor
	
	box_parent.drag(event.position - visualizer.position)
