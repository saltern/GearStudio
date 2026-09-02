extends Button

@export var controls: Array[Control]


func _toggled(toggled_on: bool) -> void:
	for control in controls:
		control.visible = toggled_on
