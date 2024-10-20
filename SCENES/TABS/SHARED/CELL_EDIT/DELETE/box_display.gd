extends Control

@export var cell_index: SpinBox
@export var offset: Vector2i

var obj_data: ObjectData
var current_cell: Cell


func _ready() -> void:
	var cell_edit: CellEdit = owner
	obj_data = cell_edit.obj_data
	cell_load(cell_index.value)
	
	cell_index.value_changed.connect(cell_load)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if !is_visible_in_tree():
		return
		
	for box_info in current_cell.boxes:
		draw_box(box_info)


func draw_box(box: BoxInfo) -> void:
	var color := Settings.box_colors[
		clampi(box.type, 0, Settings.box_colors.size() - 1)]
		
	# Using four separate draw_rect()s instead of just one
	# as drawing unfilled boxes is off by a pixel or two
	
	var pos: Vector2i = box.rect.position
	var siz: Vector2i = box.rect.size
	
	# Upper
	draw_rect(Rect2(
			pos + offset,
			Vector2i(siz.x, Settings.box_thickness)),
		color)
	
	# Lower
	draw_rect(Rect2(
			Vector2i(pos.x, pos.y + siz.y - Settings.box_thickness) + offset,
			Vector2i(siz.x, Settings.box_thickness)),
		color)
	
	# Left
	draw_rect(Rect2(
			pos + offset,
			Vector2i(Settings.box_thickness, siz.y)),
		color)
	
	# Right
	draw_rect(Rect2(
			Vector2i(pos.x + siz.x - Settings.box_thickness, pos.y) + offset,
			Vector2i(Settings.box_thickness, siz.y)),
		color)


func cell_load(cell_index: int) -> void:
	current_cell = obj_data.cells[cell_index]
