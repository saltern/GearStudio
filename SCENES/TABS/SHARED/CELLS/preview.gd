extends Node2D


func _ready() -> void:
	center_view()
	get_parent().resized.connect(center_view)


func _process(_delta: float) -> void:
	if !is_visible_in_tree():
		return
	
	position.x = clampi(position.x, -1500 + get_parent().size.x, 1500)
	position.y = clampi(position.y, -1500 + get_parent().size.y, 1500)


func center_view() -> void:
	var parent_size: Vector2 = get_parent().size
	position.x = int(parent_size.x / 2)
	position.y = int(parent_size.y / 2)


func zoom_in() -> void:	
	if scale == Vector2(4,4):
		Status.set_status("Already at max zoom!")
		return
	
	scale += Vector2.ONE
	clamp_zoom()
	center_view()
	Status.set_status("Zoomed in (%sx)" % scale.x)


func zoom_out() -> void:
	if scale == Vector2.ONE:
		Status.set_status("Already at min zoom!")
		return
	
	scale -= Vector2.ONE	
	clamp_zoom()
	center_view()
	Status.set_status("Zoomed out (%sx)" % scale.x)


func clamp_zoom() -> void:
	scale = Vector2(
		clampi(scale.x, 1, 4),
		clampi(scale.y, 1, 4))
