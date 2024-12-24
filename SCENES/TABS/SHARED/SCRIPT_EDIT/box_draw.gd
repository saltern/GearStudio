extends Control

var box_list: Array[BoxInfo]
var scale_factor: Vector2 = Vector2(1.0, 1.0)

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	script_edit.cell_updated.connect(on_cell_update)
	script_edit.cell_clear.connect(clear_boxes)
	script_edit.inst_scale.connect(on_scale)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw():
	# Using four separate draw_rect()s instead of just one
	# as drawing unfilled boxes is off by a pixel or two
	
	for box in box_list:
		# Don't draw cutout boxes
		if box.box_type % 3 == 0:
			continue
		
		var color := Settings.box_colors[box.box_type]
		
		# Upper
		draw_rect(Rect2(
				Vector2(box.x_offset, box.y_offset) * scale_factor,
				Vector2i(box.width * scale_factor.x, Settings.box_thickness)),
			color)
		
		# Lower
		draw_rect(Rect2(
				Vector2(
					box.x_offset,
					box.y_offset + box.height - Settings.box_thickness) * scale_factor,
				Vector2i(box.width * scale_factor.x, Settings.box_thickness)),
			color)
		
		# Left
		draw_rect(Rect2(
				Vector2(box.x_offset, box.y_offset) * scale_factor,
				Vector2i(Settings.box_thickness, box.height * scale_factor.y)),
			color)
		
		# Right
		draw_rect(Rect2(
				Vector2(
					box.x_offset + box.width - Settings.box_thickness,
					box.y_offset) * scale_factor,
				Vector2i(Settings.box_thickness, box.height * scale_factor.y)),
			color)


func on_cell_update(cell: Cell) -> void:
	load_boxes(cell.boxes)


func clear_boxes() -> void:
	box_list = []


func load_boxes(boxes: Array[BoxInfo]) -> void:
	clear_boxes()
	box_list = boxes


#region INSTRUCTION SIMULATION
func on_scale(arguments: Array) -> void:
	var values: Array[int]
	values.assign(arguments)
	var fvalue: float = values[1] / 1000.00
	
	#print(values)
	
	match values[0]: #mode
		0:
			scale_factor.x = fvalue
			scale_factor.y = fvalue
			pass #scale = value
		1:
			scale_factor.y = fvalue
			pass #scaleY = value
		2:
			scale_factor.x += fvalue
			scale_factor.y += fvalue
			pass #scale += value
		3:
			scale_factor.y += fvalue
			pass #scaleY += value
		4:
			pass #scale = scale + (rng AND value)
		5:
			pass #scaleY = scaleY + (rng AND value)
		6:
			scale_factor.x = (scale_factor.x * (fvalue / 100.00))
			scale_factor.y = (scale_factor.y * (fvalue / 100.00))
			pass #scale = (scale * (value / 100.00))
		7:
			scale_factor.y = (scale_factor.y * (fvalue / 100.00))
			pass #scaleY = (scaleY * (value / 100.00))
#endregion
