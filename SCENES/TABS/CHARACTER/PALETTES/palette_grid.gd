extends GridContainer

@export var color_picker: ColorPicker
@export var preview: TextureRect

const CELL_SIZE: int = 16
const GRID_SIZE: int = CELL_SIZE + 1

var mouse_in: bool = false
var is_clicking: bool = false
var is_dragging: bool = false

var index_hovered: int = 0
var selection_box: bool = false
var selection_start: int = 0
var selection_end: int = 0
var selection_data: PackedByteArray
var selected: Array[bool] = []
var selecting: Array[bool] = []
var selected_count: int = 0

var pal_state: PaletteEditState


func _ready() -> void:
	selected.resize(256)
	selecting.resize(256)
	
	pal_state = SessionData.palette_state_get(
		get_owner().get_parent().get_index())
	
	color_picker.color_changed.connect(update_color)
	color_picker.color = pal_state.get_color(0)
	
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


#region Draw
func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for cell in 256:
		#region Selection in progress (prioritized)
		if selecting[cell]:
			# Inner black outline
			draw_rect(Rect2(
					GRID_SIZE * (cell % 16) + 2,
					GRID_SIZE * (cell / 16) + 2,
					GRID_SIZE - 5,
					GRID_SIZE - 5),
				Color.BLACK, false, 2)
			
			# White square
			draw_rect(Rect2(
					GRID_SIZE * (cell % 16) + 1,
					GRID_SIZE * (cell / 16) + 1,
					GRID_SIZE - 3,
					GRID_SIZE - 3),
				Color.WHITE, false, 2)
		#endregion
		
		#region Previously selected
		elif selected[cell]:
			# Inner black outline
			draw_rect(Rect2(
					GRID_SIZE * (cell % 16) + 2,
					GRID_SIZE * (cell / 16) + 2,
					GRID_SIZE - 5,
					GRID_SIZE - 5),
				Color.BLACK, false, 2)
			
			# Red square
			draw_rect(Rect2(
					GRID_SIZE * (cell % 16) + 1,
					GRID_SIZE * (cell / 16) + 1,
					GRID_SIZE - 3,
					GRID_SIZE - 3),
				Color.RED, false, 2)
		#endregion
	
	if Input.is_key_pressed(KEY_CTRL):
		draw_paste_region()
		
	#region Hovered color
	if index_hovered > -1:
		# Inner black outline
		draw_rect(Rect2(
				GRID_SIZE * (index_hovered % 16) + 2,
				GRID_SIZE * (index_hovered / 16) + 2,
				GRID_SIZE - 5,
				GRID_SIZE - 5),
			Color.BLACK, false, 2)
		
		# Cyan square
		draw_rect(Rect2(
				GRID_SIZE * (index_hovered % 16) + 1,
				GRID_SIZE * (index_hovered / 16) + 1,
				GRID_SIZE - 3,
				GRID_SIZE - 3),
			Color.CYAN, false, 2)
	#endregion
#endregion


#region Input
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
			if is_dragging:
				selecting = get_selection()
				shader_set_highlight()
		
		KEY_C:
			if event.ctrl_pressed:
				set_copy_data()
		
		KEY_V:
			if event.ctrl_pressed:
				paste()
		
		KEY_ESCAPE:
			selected_count = 0
			selected.resize(0)
			selected.resize(256)


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
			selecting = get_selection()
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				mouse_click(event.pressed, event.position, false)
			
			MOUSE_BUTTON_RIGHT:
				mouse_click(event.pressed, event.position, true)
	
	shader_set_highlight()


func mouse_click(pressed: bool, at: Vector2i, subtractive: bool) -> void:
	if not mouse_in:
		return
	
	if pressed and not is_clicking:
		selection_start = get_color_index_at(at)
		selection_end = selection_start
	
	is_clicking = pressed
	
	if is_clicking:
		# Click and drag
		if is_dragging:
			selection_end = get_color_index_at(at)
			selecting = get_selection()
		
		else:
			color_hover(get_color_index_at(at))
			selection_start = get_color_index_at(at)
	
	else:
		# Click, drag, and release
		if is_dragging:
			var index: int = get_color_index_at(at)
			selection_end = index
			is_dragging = false
			color_picker.color = pal_state.get_color(index)
			set_selection(subtractive)
		
		# Click and release on grid
		else:
			var index: int = get_color_index_at(at)
			selection_start = index
			selection_end = index
			color_picker.color = pal_state.get_color(index)
			selecting = get_selection()
			set_selection(subtractive)

	
func get_color_index_at(at: Vector2i) -> int:
	return CELL_SIZE * (at.y / (CELL_SIZE + 1)) + (at.x / (CELL_SIZE + 1))
#endregion


#region Copy/Paste
func set_copy_data() -> void:
	var copy_data: Array[Color] = []
	
	for cell in 256:
		if !selected[cell]:
			continue
		
		copy_data.append(pal_state.get_color(cell))
	
	Clipboard.pal_selection = selected.duplicate()
	Clipboard.pal_data = copy_data


func draw_paste_region() -> void:
	if Clipboard.pal_data.size() < 1:
		return
	
	if selected_count > 0:
		draw_paste_at_selection()
	else:
		draw_paste_at_cursor()


func draw_paste_at_cursor() -> void:
	var start_index: int = 0
	var current_color: int = 0
	
	for cell in 256:
		if Clipboard.pal_selection[cell]:
			start_index = cell
			break
	
	if index_hovered < 0 || index_hovered > 255:
		return
	
	for cell in 256:
		var this_index: int = index_hovered - start_index + cell
		
		if !Clipboard.pal_selection[cell]:
			continue
		
		if this_index < 0 || this_index > 255:
			continue
		
		# Actual color to paste
		draw_rect(Rect2(
				GRID_SIZE * (this_index % 16),
				GRID_SIZE * (this_index / 16),
				CELL_SIZE,
				CELL_SIZE),
			Clipboard.pal_data[current_color])
		
		current_color += 1
		
		draw_rect(Rect2(
				GRID_SIZE * (this_index % 16) + 2,
				GRID_SIZE * (this_index / 16) + 2,
				GRID_SIZE - 5,
				GRID_SIZE - 5),
			Color.BLACK, false, 2)
		
		draw_rect(Rect2(
				GRID_SIZE * ((this_index) % 16) + 1,
				GRID_SIZE * ((this_index) / 16) + 1,
				GRID_SIZE - 3,
				GRID_SIZE - 3),
			Color.PURPLE, false, 2)


func draw_paste_at_selection() -> void:
	var current_color: int = 0
	
	for cell in 256:
		if selected[cell]:
			# Color preview
			draw_rect(Rect2(
					GRID_SIZE * (cell % 16),
					GRID_SIZE * (cell / 16),
					CELL_SIZE,
					CELL_SIZE),
				Clipboard.pal_data[current_color])
			
			current_color = wrapi(
				current_color + 1, 0, Clipboard.pal_data.size())
		
			# Black outline
			draw_rect(Rect2(
					GRID_SIZE * (cell % 16) + 2,
					GRID_SIZE * (cell / 16) + 2,
					GRID_SIZE - 5,
					GRID_SIZE - 5),
				Color.BLACK, false, 2)
			
			# Purple square
			draw_rect(Rect2(
					GRID_SIZE * (cell % 16) + 1,
					GRID_SIZE * (cell / 16) + 1,
					GRID_SIZE - 3,
					GRID_SIZE - 3),
				Color.PURPLE, false, 2)


func paste() -> void:
	if Clipboard.pal_data.size() < 1:
		return
	
	if selected_count > 0:
		pal_state.paste_color_into(selected)
	else:
		pal_state.paste_color(index_hovered)
#endregion


#region Set/Get selection
func get_selection() -> Array[bool]:
	var temp_selected: Array[bool] = []
	temp_selected.resize(256)
	
	if selection_box:
		var source: int = min(selection_start, selection_end)
		var target: int = max(selection_start, selection_end)
		
		var source_row: int = source / 16
		var target_row: int = target / 16
		
		var source_cell: int = min(source % 16, target % 16)
		var target_cell: int = max(source % 16, target % 16)
		
		for row in range(source_row, target_row + 1):
			for cell in range(source_cell, target_cell + 1):
				temp_selected[row * 16 + cell] = true
	
	else:
		var source: int = min(selection_start, selection_end)
		var target: int = max(selection_start, selection_end)
		
		var source_row: int = source / 16
		var target_row: int = target / 16
		
		var source_cell: int = source % 16
		var target_cell: int = target % 16
		
		var start: int = clampi(16 * source_row + source_cell, 0, 256)
		var end: int = clampi(16 * target_row + target_cell, 0, 256)
		
		for cell in range(start, end + 1):
			temp_selected[cell] = true
	
	return temp_selected


func set_selection(subtractive: bool) -> void:
	if subtractive:
		for cell in 256:
			selected[cell] = selected[cell] && !selecting[cell]
			
	elif Input.is_key_pressed(KEY_SHIFT):
		for cell in 256:
			selected[cell] = selected[cell] || selecting[cell]
	
	else:
		selected = selecting.duplicate()
	
	selected_count = 0
	for cell in 256:
		selected_count += selected[cell] as int
	
	selecting.resize(0)
	selecting.resize(256)
#endregion


func update_color(new_color: Color) -> void:
	if selected_count < 1:
		Status.set_status("Nothing selected. Palette has not been modified.")
		return
	
	for cell in selected.size():
		if !selected[cell]:
			continue
		
		var color: ColorRect = get_child(cell)
		color.color = new_color
	
	pal_state.set_color(selected, new_color)
	preview.update_palette()


func shader_set_highlight() -> void:	
	get_owner().palette_shader.set_shader_parameter("highlight", selecting)


func color_hover(index: int) -> void:
	index_hovered = index
	preview.material.set_shader_parameter("hover_index", index)


#region Signals
func on_mouse_enter() -> void:
	mouse_in = true


func on_mouse_exit() -> void:
	mouse_in = false
	is_clicking = false
	color_hover(-1)


func on_palette_load(new_palette: int) -> void:
	for index in 256:		
		get_child(index).color = pal_state.get_color_in(index, new_palette)
#endregion
