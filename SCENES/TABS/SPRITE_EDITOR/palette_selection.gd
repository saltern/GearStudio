class_name PaletteSelection extends Control

signal selection_changed
signal index_clicked

const TILE_SIZE		: int = 17
const TILE_INNER	: int = 16
const TILE_OFFSET	: int = 1
const COLUMNS		: int = 16
const MAX_INDEX		: int = 255

#var sprite: BinSprite

var hover: int = -1
var dragging: bool = false
var subtract: bool = false

var selecting_start: int = -1
var selecting_min: int = -1
var selecting_max: int = -1

var selected: Array[bool]

@export var pal_helper		: PaletteEditorHelper
@export var tex_hover		: Texture2D
@export var tex_selecting	: Texture2D
@export var tex_selected	: Texture2D
@export var tex_paste		: Texture2D


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
					if event.alt_pressed:
						subtract = true
					
					if !event.shift_pressed && !subtract:
						selected.fill(false)
					
					selecting_start = index
					selecting_min = index
					selecting_max = index
				
				# On release
				else:
					if !subtract:
						index_clicked.emit(
							get_color_index_at(event.position)
						)
					
					if selecting_start > -1:
						for i: int in range(selecting_min, selecting_max + 1):
							selected[i] = !subtract
					
					subtract = false
					selecting_start = -1
					selecting_min = -1
					selecting_max = -1
	
	# Adjust selection extents if going backwards
	if dragging:
		selecting_min = mini(selecting_start, index)
		selecting_max = maxi(selecting_start, index)
		selecting_max = mini(selecting_max, pal_helper.get_color_count() - 1)
	
	# Hovering
	if index < 0 || index > (pal_helper.get_color_count() - 1):
		hover = -1
	else:
		hover = index
	
	selection_changed.emit()


func _draw() -> void:
	#region Selection
	for i: int in pal_helper.get_color_count():
		if selected[i]:
			draw_texture(
				tex_selected, Vector2(
					TILE_SIZE * (i % COLUMNS),
					TILE_SIZE * (i / COLUMNS),
				)
			)
	
	if selecting_min > -1:
		for i: int in range(selecting_min, selecting_max + 1):
			draw_texture(
				tex_selecting, Vector2(
					TILE_SIZE * (i % COLUMNS),
					TILE_SIZE * (i / COLUMNS),
				)
			)
	#endregion
	
	# Paste region
	if Input.is_key_pressed(KEY_CTRL):
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
			tex_paste, Vector2(
				TILE_SIZE * (this_index % COLUMNS),
				TILE_SIZE * (this_index / COLUMNS),
			)
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
		
			# Black outline
			draw_texture(
			tex_paste, Vector2(
				TILE_SIZE * (index % COLUMNS),
				TILE_SIZE * (index / COLUMNS),
			)
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
