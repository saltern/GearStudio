extends Control

@onready var script_edit: ScriptEdit = get_owner()

var this_cell: Cell


func _ready() -> void:
	script_edit.cell_loaded.connect(on_cell_update)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for box in this_cell.boxes:
		var type_color: int = box.type
		
		var color := Settings.box_colors[
			clampi(type_color, 0, Settings.box_colors.size() - 1)]
		
		# Using four separate draw_rect()s instead of just one
		# as drawing unfilled boxes is off by a pixel or two
		
		var rect: Rect2i = box.rect
		
		# Upper
		draw_rect(Rect2(
				rect.position,
				Vector2i(rect.size.x, Settings.box_thickness)),
			color)
		
		# Lower
		draw_rect(Rect2(
				Vector2i(rect.position.x, rect.size.y - Settings.box_thickness),
				Vector2i(rect.size.x, Settings.box_thickness)),
			color)
		
		# Left
		draw_rect(Rect2(
				rect.position,
				Vector2i(Settings.box_thickness, rect.size.y)),
			color)
		
		# Right
		draw_rect(Rect2(
				Vector2i(rect.size.x - Settings.box_thickness, 0),
				Vector2i(Settings.box_thickness, rect.size.y)),
			color)


func on_cell_update(cell: Cell) -> void:
	this_cell = cell
