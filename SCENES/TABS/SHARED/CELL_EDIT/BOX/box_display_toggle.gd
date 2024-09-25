extends CheckButton

@export var box_draw_node: Control
@export var editable_parent: Control
@export var edit_mode: CheckButton
@export var type_window_button: Button


func _ready() -> void:
	toggled.connect(toggle)


func toggle(new_value: bool) -> void:
	box_draw_node.visible = new_value
	#editable_parent.visible = new_value
	type_window_button.visible = new_value
	edit_mode.button_pressed = false
	edit_mode.toggled.emit(false)
	edit_mode.disabled = !new_value
