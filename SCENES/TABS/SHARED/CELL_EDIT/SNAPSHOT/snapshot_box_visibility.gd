extends CheckButton

@export var main_button: Button


func _ready() -> void:
	button_pressed = main_button.button_pressed


func _toggled(toggled_on: bool) -> void:
	main_button.button_pressed = toggled_on
