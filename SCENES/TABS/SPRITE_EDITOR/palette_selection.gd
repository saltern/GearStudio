class_name PaletteSelection extends Control

signal selection_changed
signal index_clicked

const TILE_SIZE		: int = 17
const TILE_INNER	: int = 16
const TILE_OFFSET	: int = 1
const COLUMNS		: int = 16
const MAX_INDEX		: int = 255

var hover: int = -1
var dragging: bool = false
var subtract: bool = false

var reorder_mode: bool = false
var reordering: bool = false
var reorder_source: int = -1
var reorder_target: int = -1

var selecting_start: int = -1
var selecting_min: int = -1
var selecting_max: int = -1

var selected: Array[bool]
var selection_min: int = -1
var selection_max: int = -1

@export var pal_helper		: PaletteEditorHelper
@export var tex_hover		: Texture2D
@export var tex_select		: Texture2D


func _ready() -> void:
	mouse_exited.connect(on_mouse_exited)
	selected.resize(256)


func _physics_process(_delta: float) -> void:
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
	
	if not event.pressed or event.echo:
		return
	
	match event.keycode:
		KEY_ESCAPE:
			deselect_all()
	
	if reorder_mode:
		return
	
	match event.keycode:
		KEY_C:
			if event.ctrl_pressed:
				pal_helper.copy()
		
		KEY_V:
			if event.ctrl_pressed:
				pal_helper.paste(hover)


func _gui_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if event is InputEventMouse:
		input_mouse(event)


func input_mouse(event: InputEventMouse) -> void:
	var index: int = get_color_index_at(event.position)
	
	# Click and drag/release
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				dragging = event.pressed
				
				# On start dragging
				if dragging:
					# Subtractive selection
					if event.alt_pressed:
						subtract = true
					
					# Shift not pressed: reset selection
					if !event.shift_pressed && !subtract:
						# Reorder mode
						if is_selected(index) && reorder_mode:
							reordering = true
							reorder_source = index
							reorder_target = index
						else:
							selected.fill(false)
					
					if !reordering:
						selecting_start = index
						selecting_min = index
						selecting_max = index
				
				# On release
				else:
					if reordering:
						pal_helper.reorder()
					
					elif !subtract:
						index_clicked.emit(
							get_color_index_at(event.position)
						)
					
					if selecting_start > -1:
						for i: int in range(selecting_min, selecting_max + 1):
							selected[i] = !subtract
					
					subtract = false
					reordering = false
					selecting_start = -1
					selecting_min = -1
					selecting_max = -1
					
					# Record selection extents
					selection_min = 0x100
					for i: int in pal_helper.get_color_count():
						if is_selected(i):
							selection_min = mini(selection_min, i)
							selection_max = i
	
	var max_index: int = pal_helper.get_color_count() - 1
	
	if dragging:
		if reordering:
			reorder_target = clampi(
				# requested displacement
				index - reorder_source,
				# left limit		right limit
				- selection_min,	max_index - selection_max
			)
			
		else:
			# Adjust selection extents if going backwards
			selecting_min = mini(selecting_start, index)
			selecting_max = maxi(selecting_start, index)
			selecting_max = mini(selecting_max, max_index)
	
	# Hovering
	if index < 0 || index > max_index:
		hover = -1
	else:
		hover = index
	
	selection_changed.emit()


func _draw() -> void:
	#region Selection
	# Selected
	for i: int in pal_helper.get_color_count():
		if is_selected(i):
			draw_texture(
				tex_select, Vector2(
					TILE_SIZE * (i % COLUMNS),
					TILE_SIZE * (i / COLUMNS),
				), Color.RED
			)
	
	# Reorder target
	if reordering:
		for i: int in pal_helper.get_color_count():
			if not is_selected(i):
				continue
			
			var index: int = i + reorder_target
			
			draw_texture(
				tex_select, Vector2(
					TILE_SIZE * (index % COLUMNS),
					TILE_SIZE * (index / COLUMNS),
				), Color.GREEN_YELLOW
			)
	
	# Selecting
	if selecting_min > -1:
		for i: int in range(selecting_min, selecting_max + 1):
			draw_texture(
				tex_select, Vector2(
					TILE_SIZE * (i % COLUMNS),
					TILE_SIZE * (i / COLUMNS),
				)
			)
	#endregion
	
	# Paste region
	if Input.is_key_pressed(KEY_CTRL) && !reorder_mode:
		draw_paste_region()
	
	#region Hovered color
	if hover > -1:
		draw_texture(
			tex_hover, Vector2(
				TILE_SIZE * (hover % COLUMNS) - 1,
				TILE_SIZE * (hover / COLUMNS) - 1,
			)
		)
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
	var color_count: int = pal_helper.get_color_count()
	
	for index: int in color_count:
		if Clipboard.pal_selection[index]:
			start_index = index
			break
	
	if hover < 0 || hover > color_count - 1:
		return
	
	for index: int in color_count:
		var this_index: int = hover - start_index + index
		
		if !Clipboard.pal_selection[index]:
			continue
		
		if this_index < 0 || this_index > color_count - 1:
			continue
		
		# Double alpha of preview color
		var preview_color: Color = Clipboard.pal_data[current_color]
		preview_color.a8 = clampi(preview_color.a8 * 2, 0x00, 0xFF)
		
		# Actual color to paste
		draw_rect(
			Rect2(
				TILE_SIZE * (this_index % COLUMNS),
				TILE_SIZE * (this_index / COLUMNS),
				TILE_INNER, TILE_INNER
			), preview_color
		)
		
		current_color += 1
		
		draw_texture(
			tex_select, Vector2(
				TILE_SIZE * (this_index % COLUMNS),
				TILE_SIZE * (this_index / COLUMNS),
			), Color.PURPLE
		)


func draw_paste_at_selection() -> void:
	var current_color: int = 0
	
	for index: int in pal_helper.get_color_count():
		if selected[index]:
			# Double alpha of preview color
			var preview_color: Color = Clipboard.pal_data[current_color]
			preview_color.a8 = clampi(preview_color.a8 * 2, 0x00, 0xFF)
		
			# Color preview
			draw_rect(
				Rect2(
					TILE_SIZE * (index % COLUMNS),
					TILE_SIZE * (index / COLUMNS),
					TILE_INNER, TILE_INNER
				), preview_color
			)
			
			current_color = wrapi(
				current_color + 1, 0, Clipboard.pal_data.size()
			)
		
			draw_texture(
				tex_select, Vector2(
					TILE_SIZE * (index % COLUMNS),
					TILE_SIZE * (index / COLUMNS),
				), Color.PURPLE
			)
#endregion


func get_color_index_at(at: Vector2i) -> int:
	return COLUMNS * (at.y / TILE_SIZE) + (at.x / TILE_SIZE)


func is_selected(index: int) -> bool:
	return selected[index]


func get_selected_count() -> int:
	var count: int = 0
	
	for item: bool in selected:
		count += item as int
	
	return count


func deselect_all() -> void:
	selecting_start = -1
	selecting_min = -1
	selecting_max = -1
	selected.fill(false)


func on_mouse_exited() -> void:
	hover = -1
	selection_changed.emit()


func get_reordered_colors() -> PackedByteArray:
	var palette: PackedByteArray = pal_helper.get_palette().duplicate()
	var reordered: PackedByteArray = []
	
	var indices: PackedInt64Array = []
	var colors: PackedColorArray = []
	
	for i: int in pal_helper.get_color_count():
		if is_selected(i):
			indices.append(i)
			colors.append(
				Color8(
					palette[4 * i + 0],
					palette[4 * i + 1],
					palette[4 * i + 2],
					palette[4 * i + 3],
				)
			)
			continue
		
		reordered.append(palette[4 * i + 0])
		reordered.append(palette[4 * i + 1])
		reordered.append(palette[4 * i + 2])
		reordered.append(palette[4 * i + 3])
	
	for i: int in indices:
		var color: Color = colors[0]
		colors.remove_at(0)
		
		reordered.insert(4 * (i + reorder_target), color.a8)
		reordered.insert(4 * (i + reorder_target), color.b8)
		reordered.insert(4 * (i + reorder_target), color.g8)
		reordered.insert(4 * (i + reorder_target), color.r8)
	
	return reordered


func get_reordered_pixels(source_pixels: PackedByteArray) -> PackedByteArray:
	var indices: PackedInt64Array = []
	var transforms: PackedByteArray = []
	var result: PackedByteArray = []
	
	for i: int in transforms.size():
		if is_selected(i):
			indices.append(i)
			continue
		
		transforms.append(i)
	
	for i: int in indices:
		transforms.insert(i + reorder_target, i)
	
	for p: int in source_pixels:
		result.append(transforms[p])
	
	return result
