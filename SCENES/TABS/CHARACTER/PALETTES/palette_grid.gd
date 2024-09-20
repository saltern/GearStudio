extends GridContainer

@export var preview: TextureRect

const CELL_SIZE: int = 16
const GRID_SIZE: int = CELL_SIZE + 1

var provider: PaletteProvider

var mouse_in: bool = false
var is_clicking: bool = false
var is_dragging: bool = false

var index_hovered: int = -1
var selection_box: bool = false
var selection_start: int = 0
var selection_end: int = 0
var selection_data: PackedByteArray
var selecting: Array[bool] = []
#var selected_count: int = 0


func _ready() -> void:
	selecting.resize(256)
	
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)
	
	for index in 256:
		var new_color := ColorRect.new()
		new_color.custom_minimum_size = Vector2(CELL_SIZE,CELL_SIZE)
		new_color.mouse_filter = MOUSE_FILTER_IGNORE
		new_color.show_behind_parent = true
		add_child(new_color)
	
	provider = get_owner().get_provider()
	provider.palette_updated.connect(on_palette_load)


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
		elif provider.colors_selected[cell]:
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
				provider.set_copy_data()
		
		KEY_V:
			if event.ctrl_pressed:
				provider.paste(index_hovered)
		
		KEY_ESCAPE:
			provider.color_selected_count = 0
			provider.color_deselect_all()


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
			provider.color_selected.emit(index)
			provider.color_set_selection(selecting, subtractive)
			selecting.resize(0)
			selecting.resize(256)
		
		# Click and release on grid
		else:
			var index: int = get_color_index_at(at)
			selection_start = index
			selection_end = index
			selecting = get_selection()
			provider.color_selected.emit(index)
			provider.color_set_selection(selecting, subtractive)
			selecting.resize(0)
			selecting.resize(256)

	
func get_color_index_at(at: Vector2i) -> int:
	return CELL_SIZE * (at.y / (CELL_SIZE + 1)) + (at.x / (CELL_SIZE + 1))
#endregion


#region Copy/Paste
func draw_paste_region() -> void:
	if Clipboard.pal_data.size() < 1:
		return
	
	if provider.color_selected_count > 0:
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
	
	for index in 256:
		if provider.colors_selected[index]:
			# Color preview
			draw_rect(Rect2(
					GRID_SIZE * (index % 16),
					GRID_SIZE * (index / 16),
					CELL_SIZE,
					CELL_SIZE),
				Clipboard.pal_data[current_color])
			
			current_color = wrapi(
				current_color + 1, 0, Clipboard.pal_data.size())
		
			# Black outline
			draw_rect(Rect2(
					GRID_SIZE * (index % 16) + 2,
					GRID_SIZE * (index / 16) + 2,
					GRID_SIZE - 5,
					GRID_SIZE - 5),
				Color.BLACK, false, 2)
			
			# Purple square
			draw_rect(Rect2(
					GRID_SIZE * (index % 16) + 1,
					GRID_SIZE * (index / 16) + 1,
					GRID_SIZE - 3,
					GRID_SIZE - 3),
				Color.PURPLE, false, 2)
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
#endregion


func shader_set_highlight() -> void:
	preview.material.set_shader_parameter("highlight", selecting)


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


func on_palette_load(palette: PackedByteArray) -> void:
	# Used for SpriteEdit...
	if palette.is_empty():
		get_parent().hide()
	else:
		get_parent().show()
	
	for index in 256:
		#get_child(index).color = Color8(0, 0, 0, 0)
		get_child(index).hide()
	
	if Settings.palette_alpha_double:
		for index in palette.size() / 4:
			var alpha: int = 4 * index + 3
			palette[alpha] = min(palette[alpha] * 2, 0xFF)
	
	for index in palette.size() / 4:
		get_child(index).show()
		get_child(index).color = Color8(
			palette[4 * index + 0],
			palette[4 * index + 1],
			palette[4 * index + 2],
			palette[4 * index + 3])
#endregion
