class_name BoxPreview extends Control

var cell_edit: CellEdit

var box_info: BoxInfo
var box_index: int = -1

var tentative_select: bool = false
var is_selected: bool = false
var being_resized: bool = false
var being_dragged: bool = false
var have_dragged: bool = false
var resizers: Array[BoxResizer] = []
var prev_rect: Rect2i

var region_preview := BoxRegionPreview.new()


func _ready() -> void:
	if cell_edit.box_drawing_mode or not cell_edit.box_edits_allowed:
		mouse_filter = MOUSE_FILTER_IGNORE
	
	mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND
	
	for i in 8:
		var resizer := BoxResizer.new()
		resizer.type = i as BoxResizer.Type
		resizer.dragged.connect(resizer_dragged)
		resizer.drag_stopped.connect(broadcast_changes)
		resizer.visible = is_selected
		resizers.append(resizer)
		add_child(resizer)
	
	z_index = 1
	
	region_preview.cell_edit = cell_edit
	region_preview.box_info = box_info
	add_child(region_preview)


func _process(_delta: float) -> void:
	if not cell_edit.box_display_regions && \
	(box_info.type & 0xFFFF == 3 or box_info.type & 0xFFFF == 6):
		hide()
	else:
		show()
	
	if not being_dragged and not being_resized:
		position = box_info.rect.position
		size = box_info.rect.size
	
	region_preview.size = size
	
	queue_redraw()


func _draw() -> void:
	if !is_visible_in_tree():
		return
	
	var color: Color = Settings.box_colors[Settings.BoxType.UNKNOWN]
	var type_color: int = box_info.type & 0xFFFF
	
	if type_color == 6:
		type_color = 3
	
	if type_color < Settings.box_colors.size():
		color = Settings.box_colors[type_color]
	
	self_modulate.a = 1.0
	
	if is_selected:
		#color = pulsate_color(color)
		self_modulate = pulsate_color(Color.WHITE)
	
	region_preview.modulate = self_modulate
	
	# Using four separate draw_rect()s instead of just one
	# as drawing unfilled boxes is off by a pixel or two
	
	# Upper
	draw_rect(Rect2(
			Vector2i.ZERO,
			Vector2i(size.x, Settings.box_thickness)),
		color)
	
	# Lower
	draw_rect(Rect2(
			Vector2i(0, size.y - Settings.box_thickness),
			Vector2i(size.x, Settings.box_thickness)),
		color)
	
	# Left
	draw_rect(Rect2(
			Vector2i.ZERO,
			Vector2i(Settings.box_thickness, size.y)),
		color)
	
	# Right
	draw_rect(Rect2(
			Vector2i(size.x - Settings.box_thickness, 0),
			Vector2i(Settings.box_thickness, size.y)),
		color)


func pulsate_color(color: Color) -> Color:
	var time: float = Engine.get_physics_frames()
	time += Engine.get_physics_interpolation_fraction()
	color.a = lerp(0.0, color.a, abs(sin(time * 0.1)))
	return color


# Clicked on box directly
func _gui_input(event: InputEvent) -> void:
	if !is_visible_in_tree():
		return
	
	if not cell_edit.box_edits_allowed:
		return
	
	if event is InputEventMouseButton:
		clicked(event)
	
	elif event is InputEventMouseMotion:
		if tentative_select && is_selected:
			tentative_select = false
			get_viewport().set_input_as_handled()
		
		if is_selected && being_dragged:
			have_dragged = true
			position += event.relative
			get_viewport().set_input_as_handled()
			
			cell_edit.box_multi_drag(box_index, event.relative)


func clicked(event: InputEventMouseButton) -> void:
	if not event.button_index == MOUSE_BUTTON_LEFT:
		return
	
	get_viewport().set_input_as_handled()
	
	# Click
	if event.pressed:
		tentative_select = true
		being_dragged = true
	
	# Release
	else:
		# Save coords box was dragged to
		if being_dragged:
			if have_dragged:
				broadcast_changes()
				cell_edit.box_multi_drag_stop(box_index)
			
			being_dragged = false
			have_dragged = false
		
		# Select/deselect
		if tentative_select && Rect2i(Vector2.ZERO, size).has_point(event.position):
			if event.shift_pressed:
				if is_selected:
					cell_edit.box_deselect(box_index)
				else:
					cell_edit.box_select(box_index)
			else:
				if cell_edit.boxes_selected.size() > 1:
					cell_edit.box_deselect_all()
					cell_edit.box_select(box_index)
				
				else:
					var was_selected = is_selected
					cell_edit.box_deselect_all()
					
					if not was_selected:
						cell_edit.box_select(box_index)
		
		tentative_select = false


func external_select(box: BoxInfo) -> void:
	if box != box_info:
		if is_selected:
			resizers_hide()
		return
	
	is_selected = true
	
	if cell_edit.boxes_selected.size() > 1:
		resizers_hide()
	else:
		resizer_visibility()
		mouse_default_cursor_shape = CursorShape.CURSOR_MOVE
		move_to_front()


func external_deselect(index: int) -> void:
	if index != box_index:
		if cell_edit.boxes_selected.size() == 1:
			resizer_visibility()
		return
	
	external_deselect_all()


func external_deselect_all() -> void:
	is_selected = false
	resizer_visibility()
	mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND


func resizer_visibility() -> void:
	for resizer in resizers:
		resizer.visible = is_selected


func resizers_hide() -> void:
	for resizer in resizers:
		resizer.hide()


func resizer_dragged(type: BoxResizer.Type, motion: Vector2) -> void:
	being_resized = true
	
	prev_rect = Rect2i(position, size)
	
	match type:
		BoxResizer.Type.UP_LEFT:
			position += motion
			size -= motion
		
		BoxResizer.Type.UP:
			position.y += motion.y
			size.y -= motion.y
		
		BoxResizer.Type.UP_RIGHT:
			position.y += motion.y
			size.y -= motion.y
			size.x += motion.x
		
		BoxResizer.Type.RIGHT:
			size.x += motion.x
		
		BoxResizer.Type.DOWN_RIGHT:
			size += motion
		
		BoxResizer.Type.DOWN:
			size.y += motion.y
		
		BoxResizer.Type.DOWN_LEFT:
			position.x += motion.x
			size.x -= motion.x
			size.y += motion.y
		
		BoxResizer.Type.LEFT:
			position.x += motion.x
			size.x -= motion.x

	clamp_rect()


func clamp_rect() -> void:
	if size.x < 1:
		size.x = 1
	
	if size.y < 1:
		size.y = 1
	
	if position.x >= prev_rect.position.x + prev_rect.size.x:
		position.x = prev_rect.position.x + prev_rect.size.x - 1
		size.x = 1
	
	if position.y >= prev_rect.position.y + prev_rect.size.y:
		position.y = prev_rect.position.y + prev_rect.size.y - 1
		size.y = 1
	
	prev_rect = Rect2i(position, size)


func broadcast_changes() -> void:
	being_resized = false
	cell_edit.box_set_rect_for(box_index, Rect2i(position, size))


func multi_drag(index: int, motion: Vector2) -> void:
	if index != box_index and is_selected:
		being_dragged = true
		position += motion


func multi_drag_stop(index: int) -> void:
	if index == box_index:
		return

	being_dragged = false
	
	if is_selected:
		broadcast_changes()


func check_enable(_enabled: bool) -> void:
	if cell_edit.box_drawing_mode or not cell_edit.box_edits_allowed:
		mouse_filter = MOUSE_FILTER_IGNORE
	
	else:
		mouse_filter = MOUSE_FILTER_STOP
