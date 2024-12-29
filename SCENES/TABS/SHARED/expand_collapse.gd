extends Control

@export var collapsible: Control
@export var collapse_parent: bool = false


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	if not event.pressed:
		return
	
	if event.button_index == MOUSE_BUTTON_LEFT:
		toggle_collapsible()


func toggle_collapsible() -> void:
	collapsible.visible = !collapsible.visible

	if not collapse_parent:
		return
	
	if collapsible.visible:
		(get_parent() as Control).size_flags_vertical = Control.SIZE_EXPAND_FILL
	else:
		(get_parent() as Control).size_flags_vertical = Control.SIZE_FILL
