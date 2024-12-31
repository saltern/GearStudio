extends Control

@export var box_display_toggle: CheckButton
@export var sprite_handler: Control

var box_list: Array[BoxInfo]

var scale_x: int = -1
var scale_y: int = -1
var scale_factor: Vector2 = Vector2(1.0, 1.0)

var angle: int = 0

@onready var script_edit: ScriptEdit = owner
@onready var draw_offset: Vector2 = -position


func _ready() -> void:
	box_display_toggle.toggled.connect(toggle_display)
	script_edit.cell_clear.connect(clear_boxes)
	script_edit.inst_cell.connect(on_cell)
	sprite_handler.scale_set.connect(on_scale)


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
		
		var top: float = box.y_offset * scale_factor.y
		top += draw_offset.y
		
		var left: float = box.x_offset * scale_factor.x
		left += draw_offset.x
		
		var right: float = (box.x_offset + box.width) * scale_factor.x
		right -= Settings.box_thickness
		right += draw_offset.x
		
		var bottom: float = (box.y_offset + box.height) * scale_factor.y
		bottom -= Settings.box_thickness
		bottom += draw_offset.y
		
		var horz: float = box.width * scale_factor.x
		var vert: float = box.height * scale_factor.y
		
		# Upper
		draw_rect(Rect2(
				Vector2(left, top), Vector2i(horz, Settings.box_thickness)
			), color
		)
		
		# Left
		draw_rect(Rect2(
				Vector2(left, top), Vector2i(Settings.box_thickness, vert)
			), color
		)
		
		# Lower
		draw_rect(Rect2(
				Vector2(left, bottom), Vector2i(horz, Settings.box_thickness)
			), color
		)
		
		# Right
		draw_rect(Rect2(
				Vector2(right, top), Vector2i(Settings.box_thickness, vert)
			), color
		)


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


func on_scale(scale_x: float, scale_y: float) -> void:
	if scale_x == -1:
		scale_factor.x = 1.0
	else:
		scale_factor.x = float(scale_x) / 1000.00
	
	if scale_y == -1:
		scale_factor.y = scale_factor.x
	else:
		scale_factor.y = float(scale_y) / 1000.00
#endregion
