extends Control

@export var box_type: SpinBox
@export var collision_toggle: CheckButton
@export var collision_x: SteppingSpinBox
@export var collision_y: SteppingSpinBox
@export var collision_width: SteppingSpinBox
@export var collision_height: SteppingSpinBox

@warning_ignore("unused_signal")
signal box_changed


var drawing: bool = false
var drawing_box: Rect2i

var point_a: Vector2i
var point_b: Vector2i

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	cell_edit.cell_updated.connect(on_cell_update)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw():
	var thickness: int = Settings.box_thickness
	
	if collision_toggle.button_pressed:
		var x: int = collision_x.value
		var y: int = collision_y.value
		var w: int = collision_width.value
		var h: int = collision_height.value
		
		@warning_ignore("confusable_local_declaration")
		var color: Color = Settings.box_colors[Settings.BoxType.COLLISION]
		
		# U, D, L, R
		draw_rect(Rect2(x, y, w, thickness), color)
		draw_rect(Rect2(x, y + h - thickness, w, thickness), color)
		draw_rect(Rect2(x, y, thickness, h), color)
		draw_rect(Rect2(x + w - thickness, y, thickness, h), color)
	
	if not drawing:
		return
	
	var time: float = Engine.get_physics_frames() + \
		Engine.get_physics_interpolation_fraction()
	
	var color: Color = Color.WHITE
	
	color.a = abs(sin(time * 0.1))
	
	# Using four separate draw_rect()s instead of just one
	# as drawing unfilled boxes is off by a pixel or two
	
	# Upper
	draw_rect(Rect2(
			drawing_box.position,
			Vector2i(drawing_box.size.x, thickness)),
		color)
	
	# Lower
	draw_rect(Rect2(
			Vector2i(
				drawing_box.position.x,
				drawing_box.position.y + drawing_box.size.y - thickness),
			Vector2i(drawing_box.size.x, thickness)),
		color)
	
	# Left
	draw_rect(Rect2(
			drawing_box.position,
			Vector2i(thickness, drawing_box.size.y)),
		color)
	
	# Right
	draw_rect(Rect2(
			Vector2i(
				drawing_box.position.x + drawing_box.size.x - thickness,
				drawing_box.position.y),
			Vector2i(thickness, drawing_box.size.y)),
		color)


func on_cell_update(cell: BinCell) -> void:
	load_boxes(cell.boxes)


func load_boxes(boxes: Array[BinBoxInfo]) -> void:
	for box in get_children():
		box.queue_free()
	
	for box in boxes.size():
		var this_box: BinBoxInfo = boxes[box]
		var new_box := BoxPreview.new()
		
		cell_edit.box_selected.connect(new_box.external_select)
		cell_edit.box_deselected_all.connect(new_box.external_deselect_all)
		cell_edit.box_deselected.connect(new_box.external_deselect)
		cell_edit.box_editing_toggled.connect(new_box.check_enable)
		cell_edit.box_drawing_mode_changed.connect(new_box.check_enable)
		cell_edit.box_multi_dragged.connect(new_box.multi_drag)
		cell_edit.box_multi_drag_stopped.connect(new_box.multi_drag_stop)
		new_box.cell_edit = cell_edit
		new_box.box_info = this_box
		new_box.box_index = box
		new_box.mouse_filter = Control.MOUSE_FILTER_PASS
		
		add_child(new_box)


func start_drawing(at: Vector2) -> void:
	drawing = true
	point_a = at as Vector2i / get_zoom()
	point_b = at as Vector2i / get_zoom()
	drag(at)


func drag(at: Vector2) -> void:
	if not drawing:
		return
	
	at /= get_zoom()
	
	point_b = at as Vector2i
	
	drawing_box = get_box_rect()


func stop_drawing(at: Vector2, finished: bool) -> void:
	if not drawing:
		return
	
	drawing = false
	
	if not finished:
		return
	
	point_b = at as Vector2i / get_zoom()
	
	var new_box_rect = get_box_rect()
	var new_box := BinBoxInfo.new()
	
	new_box.box_type = box_type.value as int
	new_box.x_offset = new_box_rect.position.x
	new_box.y_offset = new_box_rect.position.y
	new_box.width = new_box_rect.size.x
	new_box.height = new_box_rect.size.y
	new_box.crop_x_offset = 0
	new_box.crop_y_offset = 0
	
	cell_edit.box_append(new_box)


func get_box_rect() -> Rect2i:
	var rect_pos: Vector2i = Vector2i(
		min(point_a.x, point_b.x),
		min(point_a.y, point_b.y))
	
	var rect_size: Vector2i = Vector2i(
		max(point_a.x, point_b.x) - rect_pos.x,
		max(point_a.y, point_b.y) - rect_pos.y)
	
	return Rect2i(rect_pos, rect_size)


func get_zoom() -> int:
	return get_global_transform().get_scale().x as int
