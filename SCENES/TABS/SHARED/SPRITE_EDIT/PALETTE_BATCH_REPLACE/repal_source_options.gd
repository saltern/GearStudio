extends VBoxContainer

@export var button: CheckBox


func _ready() -> void:
	visible = button.button_pressed
	button.toggled.connect(on_button_toggled)


func on_button_toggled(toggled_on: bool) -> void:
	visible = toggled_on
