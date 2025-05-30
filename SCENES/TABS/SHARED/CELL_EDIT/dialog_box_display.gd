extends Control

@export var cell_index: SpinBox
@export var offset: Vector2i
@export var match_cell_editor: bool
@export var box_display_toggle: CheckButton

var obj_data: Dictionary
var current_cell: Cell

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	obj_data = cell_edit.obj_data
	
	if obj_data.has("cells"):
		cell_load(cell_index.value)
	
	cell_index.value_changed.connect(cell_load)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if !is_visible_in_tree():
		return
		
	for box_info in current_cell.boxes:
		if match_cell_editor:
			if not cell_edit.box_display_types[box_info.box_type]:
				continue
			if not box_display_toggle.button_pressed:
				continue
		
		draw_box(box_info)


func draw_box(box: BoxInfo) -> void:
	var color := Settings.box_colors[
		clampi(box.box_type, 0, Settings.box_colors.size() - 1)]
		
	# Using four separate draw_rect()s instead of just one
	# as drawing unfilled boxes is off by a pixel or two
	
	var pos: Vector2i = Vector2i(box.x_offset, box.y_offset)
	var siz: Vector2i = Vector2i(box.width, box.height)
	
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


func cell_load(index: int) -> void:
	current_cell = obj_data.cells[index]
