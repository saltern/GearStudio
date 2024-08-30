class_name PaletteColor extends ColorRect

signal hovered
signal clicked

var index: int = 0
var selected: bool = false


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2i(16, 16)


#func _process(_delta: float) -> void:
	#queue_redraw()
#
#
#func _draw() -> void:
	#if selected:
		#draw_rect(Rect2(0, 0, 17, 17), Color.RED, false, 1)


#func _gui_input(event: InputEvent) -> void:
	#if not event is InputEventMouse:
		#return
		#
	#if not event is InputEventMouseButton:
		#hovered.emit(get_index())
	#
	#elif event.pressed:
		#clicked.emit(get_index())
