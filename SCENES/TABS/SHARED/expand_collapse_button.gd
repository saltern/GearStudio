extends Button

@export var collapsible: Control


func _ready() -> void:
	toggle_mode = true
	check_state()


func _toggled(toggled_on: bool) -> void:
	collapsible.visible = toggled_on


func check_state() -> void:
	button_pressed = collapsible.visible
