extends CheckButton

@export var main_button: Button


func _ready() -> void:
	button_pressed = main_button.button_pressed
	main_button.toggled.connect(toggle_no_signal)


func _toggled(toggled_on: bool) -> void:
	main_button.button_pressed = toggled_on


func toggle_no_signal(toggled_on: bool) -> void:
	set_pressed_no_signal(toggled_on)
