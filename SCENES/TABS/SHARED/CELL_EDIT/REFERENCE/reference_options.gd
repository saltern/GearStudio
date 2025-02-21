extends VBoxContainer

@export var button: Button


func _ready() -> void:
	button.toggled.connect(set_visibility)
	check_state()


func set_visibility(on: bool) -> void:
	visible = on


func check_state() -> void:
	set_visibility(button.button_pressed)
