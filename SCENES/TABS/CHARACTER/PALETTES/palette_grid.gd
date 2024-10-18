class_name PaletteGrid extends GridContainer

signal color_selected

@export var preview: TextureRect
@export var color_picker: ColorPicker

const CELL_SIZE: int = 16
const GRID_SIZE: int = CELL_SIZE + 1

var cell_texture: Texture2D = preload(
	"res://GRAPHICS/CHECKERBOARD_PAL.PNG")

var provider: PaletteProvider

var mouse_in: bool = false
var is_clicking: bool = false
var is_dragging: bool = false

var index_hovered: int = -1
var selection_box: bool = false
var selection_start: int = 0
var selection_end: int = 0
var selected: Array[bool] = []
var selecting: Array[bool] = []


func _ready() -> void:
	# Remove focus from other controls when clicking on this one
	focus_mode = FocusMode.FOCUS_CLICK
	
	selected.resize(256)
	selecting.resize(256)
	
	provider = get_owner().get_provider()

	if owner is SpriteEdit and provider.obj_data.has_palettes():
		get_parent().queue_free()
		return
	
	provider.palette_updated.connect(on_palette_load)
	
	if color_picker:
		color_picker.color_changed.connect(color_set)
		color_selected.connect(color_picker.on_color_selected)
	
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)
	
	for index in 256:
		var new_color := ColorRect.new()
		new_color.custom_minimum_size = Vector2(CELL_SIZE,CELL_SIZE)
		new_color.mouse_filter = MOUSE_FILTER_IGNORE
		new_color.show_behind_parent = true
		add_child(new_color)


#region Draw
func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var color_count: int = provider.palette_get_color_count()
	
	for cell in min(get_child_count(), color_count):
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
				provider.set_copy_data(selected)
		
		KEY_V:
			if event.ctrl_pressed:
				provider.paste(index_hovered, selected)
		
		KEY_ESCAPE:
			color_deselect_all()


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouse:
		return
	
	if event.position.x > 16 * (CELL_SIZE + 1):
		return
	
	match provider.palette_get_color_count():
		16:
			if event.position.y > CELL_SIZE + 1:
				return
		
		256:
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
			color_set_selection(subtractive)
			selecting.resize(0)
			selecting.resize(256)
		
		# Click and release on grid
		else:
			var index: int = get_color_index_at(at)
			selection_start = index
			selection_end = index
			selecting = get_selection()
			color_set_selection(subtractive)
			selecting.resize(0)
			selecting.resize(256)

	
func get_color_index_at(at: Vector2i) -> int:
	return CELL_SIZE * (at.y / (CELL_SIZE + 1)) + (at.x / (CELL_SIZE + 1))
#endregion


#region Selection
func color_deselect_all() -> void:
	selected.resize(0)
	selected.resize(256)


func color_set_selection(subtractive: bool) -> void:
	var color_count: int = provider.palette_get_color_count()
	
	if subtractive:
		for index in color_count:
			selected[index] = selected[index] and not selecting[index]
			
	elif Input.is_key_pressed(KEY_SHIFT):
		for index in color_count:
			selected[index] = selected[index] or selecting[index]
	
	else:
		selected = selecting.duplicate()

	if get_selected_count() > 0:
		color_selected.emit(selected.rfind(true))


func get_selected_count() -> int:
	var count: int = 0
	
	for is_selected in selected:
		count += is_selected as int
	
	return count
#endregion


#region Setting colors
func color_set(color: Color) -> void:
	provider.palette_set_color(color, selected)
#endregion


#region Copy/Paste
func draw_paste_region() -> void:
	if Clipboard.pal_data.size() < 1:
		return
	
	if get_selected_count() > 0:
		draw_paste_at_selection()
	else:
		draw_paste_at_cursor()


func draw_paste_at_cursor() -> void:
	var start_index: int = 0
	var current_color: int = 0
	var color_count: int = provider.palette_get_color_count()
	
	for cell in color_count:
		if Clipboard.pal_selection[cell]:
			start_index = cell
			break
	
	if index_hovered < 0 || index_hovered > color_count - 1:
		return
	
	for cell in color_count:
		var this_index: int = index_hovered - start_index + cell
		
		if !Clipboard.pal_selection[cell]:
			continue
		
		if this_index < 0 || this_index > color_count - 1:
			continue
		
		# Draw background cell
		draw_texture_rect(cell_texture,
			Rect2(
				GRID_SIZE * (this_index % 16) - 1,
				GRID_SIZE * (this_index / 16) - 1,
				cell_texture.get_size().x,
				cell_texture.get_size().y,
			), false)
		
		# Double alpha of preview color
		var preview_color: Color = Clipboard.pal_data[current_color]
		preview_color.a8 = clampi(preview_color.a8 * 2, 0x00, 0xFF)
		
		# Actual color to paste
		draw_rect(Rect2(
				GRID_SIZE * (this_index % 16),
				GRID_SIZE * (this_index / 16),
				CELL_SIZE,
				CELL_SIZE),
			preview_color)
		
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
	var color_count: int = provider.palette_get_color_count()
	
	for index in color_count:
		if selected[index]:
			# Draw background cell
			draw_texture_rect(cell_texture,
				Rect2(
					GRID_SIZE * (index % 16) - 1,
					GRID_SIZE * (index / 16) - 1,
					cell_texture.get_size().x,
					cell_texture.get_size().y,
				), false)
			
			# Double alpha of preview color
			var preview_color: Color = Clipboard.pal_data[current_color]
			preview_color.a8 = clampi(preview_color.a8 * 2, 0x00, 0xFF)
		
			# Color preview
			draw_rect(Rect2(
					GRID_SIZE * (index % 16),
					GRID_SIZE * (index / 16),
					CELL_SIZE,
					CELL_SIZE),
				preview_color)
			
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
		get_parent().custom_minimum_size.y = 17 * (palette.size() / 64) + 1
		custom_minimum_size.y = get_parent().custom_minimum_size.y - 1
	
	for index in 256:
		get_child(index).hide()
	
	for index in palette.size() / 4:
		get_child(index).show()
		var alpha: int = palette[4 * index + 3]
		
		get_child(index).color = Color8(
			palette[4 * index + 0],
			palette[4 * index + 1],
			palette[4 * index + 2],
			min(alpha * 2, 0xFF))
#endregion
