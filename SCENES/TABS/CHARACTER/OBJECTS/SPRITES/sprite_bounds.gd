extends Control

var draw_bounds: bool = true

var bounds: Rect2i


func _process(_delta: float) -> void:
	queue_redraw()


func update_mode(new_value: bool) -> void:
	visible = new_value


func _draw() -> void:
	draw_rect(bounds, Color.BLACK, true)
