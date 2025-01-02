extends Button

enum Direction {
	LEFT,
	UP,
	DOWN,
	RIGHT,
}

@export var direction: Direction

var pre_drag: bool = false
var dragging: bool = false
var warping: bool = false

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	button_down.connect(pre_drag_start)
	button_up.connect(drag_end)


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
	
	if warping:
		return
	
	if pre_drag:
		pre_drag = false
		dragging = true
		drag_start()
	
	if not dragging:
		return
	
	drag(event.relative)


func pre_drag_start() -> void:
	pre_drag = true


func drag_start() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	pre_drag = false


func drag_end() -> void:
	if pre_drag:
		pre_drag = false
		single_click()
	
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	DisplayServer.warp_mouse(global_position + size / 2)
	dragging = false


func single_click() -> void:
	match direction:
		Direction.LEFT:
			cell_edit.sprite_set_position_x(
				cell_edit.this_cell.sprite_x_offset - 1
			)
		
		Direction.RIGHT:
			cell_edit.sprite_set_position_x(
				cell_edit.this_cell.sprite_x_offset + 1
			)
		
		Direction.UP:
			cell_edit.sprite_set_position_y(
				cell_edit.this_cell.sprite_y_offset - 1
			)
		
		Direction.DOWN:
			cell_edit.sprite_set_position_y(
				cell_edit.this_cell.sprite_y_offset + 1
			)


func drag(movement: Vector2i) -> void:
	if warping:
		return
	
	match direction:
		Direction.LEFT, Direction.RIGHT:
			if movement.x == 0:
				return
			
			cell_edit.sprite_set_position_x(
				cell_edit.this_cell.sprite_x_offset + movement.x
			)
		
		_:
			if movement.y == 0:
				return
			
			cell_edit.sprite_set_position_y(
				cell_edit.this_cell.sprite_y_offset + movement.y
			)
