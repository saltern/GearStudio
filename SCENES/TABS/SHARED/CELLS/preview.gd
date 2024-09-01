extends Node2D


func _ready() -> void:
	center_view()
	get_parent().resized.connect(center_view)


func _process(_delta: float) -> void:
	position.x = clampi(position.x, -1500 * scale.x, get_parent().size.x - 500 * scale.x)
	position.y = clampi(position.y, -1500 * scale.y, get_parent().size.y - 500 * scale.y)


func center_view() -> void:
	var parent_size = get_parent().get_parent().size
	position.x = int(-1000 * scale.x) + int(parent_size.x / 2)
	position.y = int(-1000 * scale.y) + int(parent_size.y / 2)


func zoom_in() -> void:
	scale *= 2
	clamp_zoom()
	center_view()


func zoom_out() -> void:
	scale /= 2
	clamp_zoom()
	center_view()


func clamp_zoom() -> void:
	scale = Vector2(
		clampi(scale.x, 1, 4),
		clampi(scale.y, 1, 4),
	)
