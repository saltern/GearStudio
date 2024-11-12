class_name BoxRegionPreview extends Control

var cell_edit: CellEdit
var box_info: BoxInfo


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	show_behind_parent = true
	z_index = -1


func _process(_delta: float) -> void:
	visible = (box_info.box_type == 3 or box_info.box_type == 6) and \
		get_parent().is_selected
	
	queue_redraw()


func _draw() -> void:
	position = 8 * Vector2(
		box_info.crop_x_offset, box_info.crop_y_offset)
	
	position += Vector2(
		cell_edit.this_cell.sprite_x_offset,
		cell_edit.this_cell.sprite_y_offset)
	position -= Vector2(128, 128)
	
	var thickness: int = Settings.box_thickness
	var color: Color
	
	if box_info.box_type == 3:
		color = Settings.box_colors[Settings.BoxType.REGION_B]
	else:
		color = Settings.box_colors[Settings.BoxType.REGION_F]
	
	color.a /= 2.0
	
	# Upper
	draw_rect(Rect2(
			Vector2i(thickness, 0),
			Vector2i(size.x - thickness * 2, thickness)),
		color)
	
	# Lower
	draw_rect(Rect2(
			Vector2i(thickness, size.y - thickness),
			Vector2i(size.x - thickness * 2, thickness)),
		color)
	
	# Left
	draw_rect(Rect2(
			Vector2i.ZERO,
			Vector2i(thickness, size.y)),
		color)
	
	# Right
	draw_rect(Rect2(
			Vector2i(size.x - thickness, 0),
			Vector2i(thickness, size.y)),
		color)
