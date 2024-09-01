class_name BoxPreview extends Control

const LINE_THICKNESS: int = 2

var box_info: BoxInfo

var box_colors: Array[Color] = [
	Color.YELLOW, Color.RED, Color.GREEN, Color.CYAN, Color.PURPLE]

var box_index: int = -1
var box_type: int = 0

var tentative_select: bool = false
var is_selected: bool = false
var being_resized: bool = false
var being_dragged: bool = false
var have_dragged: bool = false
var resizers: Array[BoxResizer] = []


func _ready() -> void:
	mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND
	
	for i in 8:
		var resizer := BoxResizer.new()
		resizer.type = i as BoxResizer.Type
		resizer.dragged.connect(resizer_dragged)
		resizer.drag_stopped.connect(broadcast_changes)
		resizer.visible = is_selected
		resizers.append(resizer)
		add_child(resizer)


func _process(_delta: float) -> void:
	if !SessionData.box_get_display_regions() && \
	(box_type == 3 || box_type == 6):
		hide()
	else:
		show()
	
	if !being_dragged && !being_resized:
		position = box_info.rect.position
		size = box_info.rect.size
	
	queue_redraw()


func _draw() -> void:
	if !is_visible_in_tree():
		return
	
	var color: Color = Color.WHITE
	
	if box_type < box_colors.size():
		color = box_colors[box_type]
	
	if is_selected:
		color = pulsate_color(color)
	
	# Upper
	draw_rect(
		Rect2(
			Vector2.ZERO,
			Vector2(size.x, LINE_THICKNESS)),
		color)
	
	# Lower
	draw_rect(
		Rect2(
			Vector2(0, size.y - LINE_THICKNESS),
			Vector2(size.x, LINE_THICKNESS)),
		color)
	
	# Left
	draw_rect(
		Rect2(
			Vector2.ZERO,
			Vector2(LINE_THICKNESS, size.y)),
		color)
	
	# Right
	draw_rect(
		Rect2(
			Vector2(size.x - LINE_THICKNESS, 0),
			Vector2(LINE_THICKNESS, size.y)),
		color)


func resizer_visibility() -> void:
	for resizer in resizers:
		resizer.visible = is_selected


# Clicked on box directly
func _gui_input(event: InputEvent) -> void:
	if !is_visible_in_tree():
		return
	
	if !SessionData.box_get_edits_allowed():
		return
	
	if event is InputEventMouseButton:
		clicked(event)
	
	elif event is InputEventMouseMotion:
		if tentative_select && is_selected:
			tentative_select = false
		
		if is_selected && being_dragged:
			have_dragged = true
			position += event.relative


func external_select(box: BoxInfo) -> void:
	if box != box_info:
		external_deselect()
		return
	
	is_selected = true
	resizer_visibility()
	mouse_default_cursor_shape = CursorShape.CURSOR_MOVE


func external_deselect() -> void:
	is_selected = false
	resizer_visibility()
	mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND


func pulsate_color(color: Color) -> Color:
	var time: float = Engine.get_physics_frames()
	time += Engine.get_physics_interpolation_fraction()
	color.a = abs(sin(time * 0.1))
	return color


func clicked(event: InputEventMouseButton) -> void:
	if not event.button_index == MOUSE_BUTTON_LEFT:
		return
	
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
			
			being_dragged = false
			have_dragged = false
		
		# Select/deselect
		if tentative_select && Rect2i(Vector2.ZERO, size).has_point(event.position):
			if is_selected:
				SessionData.box_deselect_all()
			
			else:
				SessionData.box_select(box_index)
		
		tentative_select = false


func resizer_dragged(type: BoxResizer.Type, motion: Vector2) -> void:
	being_resized = true
	
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

		BoxResizer.Type.CENTER:
			position += motion


func broadcast_changes() -> void:
	being_resized = false
	SessionData.box_set_rect_for(get_index(), Rect2i(position, size))
