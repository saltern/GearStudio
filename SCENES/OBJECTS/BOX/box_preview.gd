class_name BoxPreview extends Control

signal register_changes

const LINE_THICKNESS: int = 2

var box_colors: Array[Color] = [
	Color.YELLOW, Color.RED, Color.GREEN, Color.CYAN, Color.PURPLE]

var box_index: int = -1
var box_type: int = 0

var tentative_select: bool = false
var is_selected: bool = false
var being_dragged: bool = false
var resizers: Array[BoxResizer] = []

var obj_state: ObjectEditState


func _ready() -> void:
	mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND
	#mouse_filter = MOUSE_FILTER_STOP
	
	for i in 8:
		var resizer := BoxResizer.new()
		resizer.type = i as BoxResizer.Type
		resizer.dragged.connect(resizer_dragged)
		resizer.drag_stopped.connect(broadcast_changes)
		resizer.visible = is_selected
		resizers.append(resizer)
		add_child(resizer)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if !obj_state.box_display_regions && box_type == 3:
		return
	
	var color: Color = Color.WHITE
	
	if box_type < box_colors.size():
		color = box_colors[box_type]
	
	if is_selected:
		color = pulsate_color(color)
	
	# Upper
	draw_rect(
		Rect2(Vector2.ZERO, Vector2(size.x, LINE_THICKNESS)), color)
	
	# Lower
	draw_rect(
		Rect2(Vector2(0, size.y - LINE_THICKNESS), Vector2(size.x, LINE_THICKNESS)), color)
	
	# Left
	draw_rect(
		Rect2(Vector2.ZERO, Vector2(LINE_THICKNESS, size.y)), color)
	
	# Right
	draw_rect(
		Rect2(Vector2(size.x - LINE_THICKNESS, 0), Vector2(LINE_THICKNESS, size.y)), color)


# Clicked on box directly
func _gui_input(event: InputEvent) -> void:
	if not obj_state.box_edits_allowed:
		return
	
	if event is InputEventMouseButton:
		clicked(event)
	
	elif event is InputEventMouseMotion:
		if tentative_select && is_selected:
			tentative_select = false
		
		if is_selected && being_dragged:
			position += event.relative


func external_update(box: BoxInfo) -> void:
	box_type = box.type
	position = box.rect.position
	size = box.rect.size


func external_select(select: bool) -> void:
	is_selected = select
	for resizer in resizers:
		resizer.visible = select


func pulsate_color(color: Color) -> Color:
	var time: float = Engine.get_physics_frames()
	time += Engine.get_physics_interpolation_fraction()
	color.a = abs(sin(time * 0.1))
	return color


func clicked(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			# Click
			if event.pressed:
				tentative_select = true
				being_dragged = true
			
			# Release
			else:
				# Save coords box was dragged to
				if being_dragged:
					broadcast_changes()
					being_dragged = false
				
				# Select/deselect
				if tentative_select && Rect2i(Vector2.ZERO, size).has_point(event.position):
					is_selected = !is_selected
				
					# Just selected
					if is_selected:
						mouse_default_cursor_shape = CursorShape.CURSOR_MOVE
						obj_state.select_box(box_index)
					
					# Just deselected
					else:
						mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND
						obj_state.deselect_boxes()
				
				tentative_select = false
				
			# Update resizer visibility
			for resizer in resizers:
				resizer.visible = is_selected


func resizer_dragged(type: BoxResizer.Type, motion: Vector2) -> void:
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
	# Received by box parent
	register_changes.emit(box_index, Rect2i(position, size))
