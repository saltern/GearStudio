extends Node2D

const MAX_ZOOM: int = 8


func _ready() -> void:
	center_view()
	get_parent().resized.connect(center_view)


func _process(_delta: float) -> void:
	if !is_visible_in_tree():
		return
	
	position.x = clampi(position.x, -1500 * scale.x + get_parent().size.x, 1500 * scale.x)
	position.y = clampi(position.y, -1500 * scale.y + get_parent().size.y, 1500 * scale.y)


func center_view() -> void:
	var parent_size: Vector2 = get_parent().size
	position.x = int(parent_size.x / 2)
	position.y = int(parent_size.y / 2)


func zoom_in() -> void:	
	if scale == Vector2(MAX_ZOOM, MAX_ZOOM):
		Status.set_status("Already at max zoom!")
		return
	
	var parent_center: Vector2 = get_parent().size / 2
	var offset_from_center: Vector2 = (position - parent_center) / scale
	offset_from_center.x = ceil(offset_from_center.x)
	offset_from_center.y = ceil(offset_from_center.y)
	
	scale += Vector2.ONE
	clamp_zoom()
	
	center_view()
	position += offset_from_center * scale
	
	Status.set_status("Zoomed in (%sx)" % scale.x)


func zoom_out() -> void:
	if scale == Vector2.ONE:
		Status.set_status("Already at min zoom, centered view.")
		center_view()
		return
	
	var parent_center: Vector2 = get_parent().size / 2
	var offset_from_center: Vector2 = (position - parent_center) / scale
	offset_from_center.x = ceil(offset_from_center.x)
	offset_from_center.y = ceil(offset_from_center.y)
	
	scale -= Vector2.ONE
	clamp_zoom()
	
	center_view()
	position += offset_from_center * scale
	
	Status.set_status("Zoomed out (%sx)" % scale.x)


func clamp_zoom() -> void:
	scale = Vector2(
		clampi(scale.x, 1, MAX_ZOOM),
		clampi(scale.y, 1, MAX_ZOOM))
