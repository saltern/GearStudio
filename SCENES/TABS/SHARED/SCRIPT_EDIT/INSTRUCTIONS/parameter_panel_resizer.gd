extends ColorRect

@export var content_container: VBoxContainer
@export var argument_container: FoldableContainer

var dragging: bool = false


func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouse:
		return
	
	if event is InputEventMouseButton:
		if not event.is_pressed():
			dragging = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			DisplayServer.warp_mouse(global_position + size / 2)
			
		else:
			dragging = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseMotion:
		if not dragging:
			return
		
		argument_container.custom_minimum_size.y -= event.relative.y / 2
		
		# Magic numbers, I know. 
		# The entire actions panel will be nuked eventually anyway.
		argument_container.custom_minimum_size.y = clamp(
			argument_container.custom_minimum_size.y,
			46,
			content_container.size.y - 127
		)

func on_mouse_entered() -> void:
	color.a = 1.0


func on_mouse_exited() -> void:
	color.a = 0.5
