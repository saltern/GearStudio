class_name DebouncingSpinBox extends SteppingSpinBox

signal drag_ended
signal value_set

var start_value: int = 0
var dragging: bool = false


func _ready() -> void:
	value_changed.connect(drag_check)


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			if not event.pressed:
				if dragging && start_value != value:
					drag_ended.emit(value)
				
				dragging = false
				
			else:
				start_value = value
				dragging = true


func drag_check(new_value: int) -> void:
	if dragging:
		return
	
	value_set.emit(new_value)
