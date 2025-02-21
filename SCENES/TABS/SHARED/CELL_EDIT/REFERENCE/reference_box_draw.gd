extends Control

@onready var cell_edit: CellEdit = owner

var box_array: Array[BoxInfo] = []


func _ready() -> void:
	cell_edit.ref_cell_updated.connect(cell_update)
	cell_edit.ref_cell_cleared.connect(cell_clear)
	cell_edit.ref_data_cleared.connect(cell_clear)
	cell_edit.ref_data_set.connect(on_ref_data_set.unbind(1))
	cell_edit.ref_cell_index_set.connect(on_ref_cell_index_set)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for box in box_array:
		var type_color: int = box.box_type
		
		var color := Settings.box_colors[
			clampi(type_color, 0, Settings.box_colors.size() - 1)]
		
		# Using four separate draw_rect()s instead of just one
		# as drawing unfilled boxes is off by a pixel or two
		
		var rect: Rect2i = Rect2i(
			box.x_offset, box.y_offset,
			box.width, box.height
		)
		
		# Upper
		draw_rect(Rect2(
				rect.position,
				Vector2i(rect.size.x, Settings.box_thickness)),
			color)
		
		# Lower
		draw_rect(Rect2(
				Vector2i(rect.position.x, rect.position.y + rect.size.y - Settings.box_thickness),
				Vector2i(rect.size.x, Settings.box_thickness)),
			color)
		
		# Left
		draw_rect(Rect2(
				rect.position,
				Vector2i(Settings.box_thickness, rect.size.y)),
			color)
		
		# Right
		draw_rect(Rect2(
				Vector2i(rect.position.x + rect.size.x - Settings.box_thickness, rect.position.y),
				Vector2i(Settings.box_thickness, rect.size.y)),
			color)


func cell_update(cell: Cell) -> void:
	box_array = cell.boxes
	queue_redraw()


func cell_clear() -> void:
	box_array = []
	queue_redraw()


func on_ref_data_set() -> void:
	var cell_index: int = cell_edit.cell_index
	
	if cell_edit.ref_cell_index > -1:
		cell_index = cell_edit.ref_cell_index
	
	var cell: Cell = cell_edit.reference_cell_get(cell_index)
	box_array = cell.boxes


func on_ref_cell_index_set(index: int) -> void:
	if index < 0:
		index = cell_edit.cell_index
	
	cell_update(cell_edit.reference_cell_get(index))
