class_name BoxResizer extends Control

signal dragged
signal drag_stopped

enum Type {
	UP_LEFT,
	UP,
	UP_RIGHT,
	RIGHT,
	DOWN_RIGHT,
	DOWN,
	DOWN_LEFT,
	LEFT,
	CENTER,
}

const anchor_points: Dictionary = {
	Type.UP_LEFT:		[0.0, 0.0, 0.0, 0.0],
	Type.UP:			[0.5, 0.0, 0.5, 0.0],
	Type.UP_RIGHT:		[1.0, 0.0, 1.0, 0.0],
	Type.RIGHT:			[1.0, 0.5, 1.0, 0.5],
	Type.DOWN_RIGHT:	[1.0, 1.0, 1.0, 1.0],
	Type.DOWN:			[0.5, 1.0, 0.5, 1.0],
	Type.DOWN_LEFT:		[0.0, 1.0, 0.0, 1.0],
	Type.LEFT:			[0.0, 0.5, 0.0, 0.5],
}

const offsets: Dictionary = {
	Type.UP_LEFT:		Vector2i(-12, -12),
	Type.UP:			Vector2i(-06, -12),
	Type.UP_RIGHT: 		Vector2i(+00, -12),
	Type.RIGHT: 		Vector2i(+00, -06),
	Type.DOWN_RIGHT: 	Vector2i(+00, +00),
	Type.DOWN: 			Vector2i(-06, +00),
	Type.DOWN_LEFT: 	Vector2i(-12, +00),
	Type.LEFT: 			Vector2i(-12, -06),
}

const mouse_shape: Dictionary = {
	Type.UP_LEFT:		CursorShape.CURSOR_FDIAGSIZE,
	Type.UP:			CursorShape.CURSOR_VSIZE,
	Type.UP_RIGHT:		CursorShape.CURSOR_BDIAGSIZE,
	Type.RIGHT:			CursorShape.CURSOR_HSIZE,
	Type.DOWN_RIGHT:	CursorShape.CURSOR_FDIAGSIZE,
	Type.DOWN:			CursorShape.CURSOR_VSIZE,
	Type.DOWN_LEFT:		CursorShape.CURSOR_BDIAGSIZE,
	Type.LEFT:			CursorShape.CURSOR_HSIZE,
}

var dragging: bool = false
var type: Type = Type.UP_LEFT


func _ready() -> void:
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	position = offsets[type]
	custom_minimum_size = Vector2(12, 12)
	anchor_left = anchor_points[type][0]
	anchor_top = anchor_points[type][1]
	anchor_right = anchor_points[type][2]
	anchor_bottom = anchor_points[type][3]
	mouse_default_cursor_shape = mouse_shape[type]


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 12, 12), Color.BLACK)
	draw_rect(Rect2(1, 1, 10, 10), Color.LIGHT_GRAY)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			dragging = true
		
		else:
			dragging = false
			drag_stopped.emit()
			
	
	elif event is InputEventMouseMotion && dragging:
		dragged.emit(type, event.relative)
