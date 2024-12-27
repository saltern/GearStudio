extends Control

@export var box_display: CheckButton
@export var sprite_handler: Control

var box_list: Array[BoxInfo]

var scale_x: int = -1
var scale_y: int = -1
var scale_factor: Vector2 = Vector2(1.0, 1.0)

var angle: int = 0

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	box_display.toggled.connect(toggle_display)
	script_edit.cell_clear.connect(clear_boxes)
	script_edit.inst_cell.connect(on_cell)
	script_edit.inst_scale.connect(on_scale)
	script_edit.inst_rotate.connect(on_rotate)


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
					box.x_offset * scale_factor.x,
					((box.y_offset + box.height) * scale_factor.y) - Settings.box_thickness),
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
					((box.x_offset + box.width) * scale_factor.x) - Settings.box_thickness,
					box.y_offset * scale_factor.y),
				Vector2i(Settings.box_thickness, box.height * scale_factor.y)),
			color)


func toggle_display(enabled: bool) -> void:
	visible = enabled


func on_cell_update(cell: Cell) -> void:
	load_boxes(cell.boxes)


func clear_boxes() -> void:
	box_list = []


func load_boxes(boxes: Array[BoxInfo]) -> void:
	clear_boxes()
	box_list = boxes


#region INSTRUCTION SIMULATION
func on_cell(index: int) -> void:
	var cell: Cell
	
	if script_edit.obj_data["cells"].size() > index:
		cell = script_edit.obj_data["cells"][index]
	else:
		cell = Cell.new()
	
	on_cell_update(cell)


func on_scale(mode: int, value: int) -> void:
	match mode:
		0:
			scale_x = value
		1:
			scale_y = value
		2:
			scale_x += value
		3:
			scale_y += value
		4:
			# ???
			scale_x += randi_range(0, pow(256, 4) - 1) & value
			pass #scale = scale + (rng AND value)
		5:
			# ???
			scale_y += randi_range(0, pow(256, 4) - 1) & value
			pass #scaleY = scaleY + (rng AND value)
		6:
			# ???
			scale_x = (scale_x * float(value) / 100.00)
		7:
			# ???
			scale_y = (scale_y * float(value) / 100.00)
	
	# Apply
	if scale_x == -1:
		scale_factor.x = 1.0
	else:
		scale_factor.x = float(scale_x) / 1000.00
	
	if scale_y == -1:
		scale_factor.y = scale_factor.x
	else:
		scale_factor.y = float(scale_y) / 1000.00


func on_rotate(mode: int, value: int) -> void:
	match mode:
		0:
			angle = value
		1:
			if value == 0:
				angle = (angle & 0xFF) << 8
			else:
				angle = randi_range(0, pow(256, 4) - 1) & value
		2:
			angle += value
		3:
			# Unknown at this time
			# angle = localid * 256
			pass
		4:
			angle += randi_range(0, pow(256, 4) - 1) & value
		5:
			angle += randi_range(0, pow(256, 4) - 1) % value
	
	rotation_degrees = (365.0 / pow(256, 2)) * angle
#endregion
