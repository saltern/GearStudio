class_name PaletteColor extends ColorRect

var selected: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2i(16, 16)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if selected:
		draw_rect(Rect2(0, 0, 17, 17), Color.RED, false, 1)


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	if not event.pressed:
		return
	
	selected = !selected
