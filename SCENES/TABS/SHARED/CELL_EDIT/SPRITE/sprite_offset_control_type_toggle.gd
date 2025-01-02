extends Label

@export var controls_a: Control
@export var controls_b: Control


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	if not event.pressed:
		return
	
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			toggle_controls()


func toggle_controls() -> void:
	if controls_a.visible:
		controls_a.hide()
		controls_b.show()
	else:
		controls_a.show()
		controls_b.hide()
