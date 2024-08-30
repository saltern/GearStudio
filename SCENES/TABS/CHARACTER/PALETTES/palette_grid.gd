extends GridContainer

@export var color_picker: ColorPicker
@export var preview: TextureRect

const CELL_SIZE: int = 16
const GRID_SIZE: int = CELL_SIZE + 1

var index_hovered: int = 0
var index_active: int = 0

var mouse_in: bool = false
var is_clicking: bool = false
var is_dragging: bool = false

var selection_box: bool = false
var selection_start: int = 0
var selection_end: int = 0
var selection_data: PackedByteArray

var pal_state: PaletteEditState


func _ready() -> void:
	pal_state = SessionData.palette_state_get(
		get_owner().get_parent().get_index())
	
	color_picker.color_changed.connect(update_color)
	color_picker.color = pal_state.get_color(index_active)
	
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)
	
	for index in 256:
		var new_color := ColorRect.new()
		new_color.custom_minimum_size = Vector2(CELL_SIZE,CELL_SIZE)
		new_color.mouse_filter = MOUSE_FILTER_IGNORE
		new_color.show_behind_parent = true
		add_child(new_color)
		

	pal_state.changed_palette.connect(on_palette_load)
	pal_state.load_palette(0)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	# Hovered color
	if index_hovered > -1:
		draw_rect(Rect2(
				GRID_SIZE * (index_hovered % 16),
				GRID_SIZE * (index_hovered / 16),
				GRID_SIZE - 1,
				GRID_SIZE - 1),
			Color.CYAN, false, 2)
			
	# Sequence selection
	if selection_start != selection_end:
		if selection_box:
			draw_box_selection()
		
		else:
			draw_sequence_selection()
		
		return
	
	# Single color selection
	draw_rect(Rect2(
			GRID_SIZE * (index_active % 16),
			GRID_SIZE * (index_active / 16),
			GRID_SIZE - 1,
			GRID_SIZE - 1),
		Color.RED, false, 2)


func draw_sequence_selection() -> void:
	var source: int = min(selection_start, selection_end)
	var target: int = max(selection_start, selection_end)
	
	# Get start and end row
	var source_row: int = source / 16
	var target_row: int = target / 16
	
	# Get start and end box in row
	var source_cell: int = source % 16
	var target_cell: int = target % 16
	
	# Single row line
	if source_row == target_row:
		var box_width: int = 1 + target - source
		
		draw_rect(Rect2(
				GRID_SIZE * source_cell,
				GRID_SIZE * source_row,
				GRID_SIZE * box_width - 1,
				GRID_SIZE - 1),
			Color.RED, false, 2)
	
	# Multi row line
	else:
		# Draw a box from the source to the end of the source's line.
		draw_rect(Rect2(
				GRID_SIZE * source_cell,
				GRID_SIZE * source_row,
				GRID_SIZE * (16 - source_cell) - 1,
				GRID_SIZE - 1),
			Color.RED, false, 2)
		
		# Draw boxes covering the entirety of any intermediate rows.
		for row in range(1 + source_row, target_row):
			draw_rect(Rect2(
					0,
					GRID_SIZE * row,
					GRID_SIZE * 16 - 1,
					GRID_SIZE - 1),
				Color.RED, false, 2)
		
		# Draw a box from the first cell to the target of the target's line.
		draw_rect(Rect2(
				0,
				GRID_SIZE * target_row,
				GRID_SIZE * (target_cell + 1) - 1,
				GRID_SIZE - 1),
			Color.RED, false, 2)


func draw_box_selection() -> void:
	var source: int = min(selection_start, selection_end)
	var target: int = max(selection_start, selection_end)
	
	var source_row: int = source / 16
	var target_row: int = target / 16
	
	var source_cell: int = min(source % 16, target % 16)
	var target_cell: int = max(source % 16, target % 16)
	
	draw_rect(Rect2(
			GRID_SIZE * source_cell,
			GRID_SIZE * source_row - 1,
			GRID_SIZE * (1 + (target_cell - source_cell)),
			GRID_SIZE * (1 + (target_row - source_row))),
		Color.RED, false, 2)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
	
	if not event.pressed or event.echo:
		return
	
	match event.keycode:
		KEY_TAB:
			selection_box = !selection_box


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouse:
		return
	
	if event.position.x > 16 * (CELL_SIZE + 1):
		return
	
	if event.position.y > 16 * (CELL_SIZE + 1):
		return
	
	if event is InputEventMouseMotion:
		var at: Vector2i = event.position
		color_hover(get_color_index_at(at))
		
		is_dragging = is_dragging or is_clicking
		
		# Constant dragging
		if is_dragging:
			selection_end = get_color_index_at(event.position)
	
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_click(event.pressed, event.position)
	
	
	if selection_start != selection_end:
		if selection_box:
			var source: int = min(selection_start, selection_end)
			var target: int = max(selection_start, selection_end)
			
			var source_row: int = source / 16
			var target_row: int = target / 16
			
			var source_cell: int = source % 16
			var target_cell: int = target % 16
			
			var highlight_array: Array[bool] = []
			highlight_array.resize(256)
			
			for row in range(source_row, target_row + 1):
				for cell in range(source_cell, target_cell + 1):
					highlight_array[row * 16 + cell] = true
		
					get_owner().palette_shader.set_shader_parameter(
						"highlight", highlight_array)
	

func get_color_index_at(at: Vector2i) -> int:
	return CELL_SIZE * (at.y / (CELL_SIZE + 1)) + (at.x / (CELL_SIZE + 1))


func mouse_click(pressed: bool, at: Vector2i) -> void:
	if not mouse_in:
		return
	
	if pressed and not is_clicking:
		selection_start = get_color_index_at(at)
		selection_end = get_color_index_at(at)
	
	is_clicking = pressed
	
	if is_clicking:
		# Click and drag
		if is_dragging:
			selection_end = get_color_index_at(at)
		
		else:
			color_hover(get_color_index_at(at))
			selection_start = get_color_index_at(at)
	
	else:
		# Click, drag, and release
		if is_dragging:
			selection_end = get_color_index_at(at)
			is_dragging = false
		
		# Click and release on grid
		if not is_dragging:
			on_color_click(get_color_index_at(at))


func color_hover(index: int) -> void:
	index_hovered = index
	preview.material.set_shader_parameter("highlight_index", index)


func on_mouse_enter() -> void:
	mouse_in = true


func on_mouse_exit() -> void:
	mouse_in = false
	is_clicking = false
	is_dragging = false
	color_hover(-1)


func on_color_click(index: int) -> void:
	index_active = index
	color_picker.color = pal_state.get_color(index)


func on_palette_load(new_palette: int) -> void:
	for index in 256:		
		get_child(index).color = pal_state.get_color_in(index, new_palette)


func update_color(new_color: Color) -> void:
	var color: ColorRect = get_child(index_active)
	color.color = new_color
	
	pal_state.set_color(index_active, new_color)
	preview.update_palette()
