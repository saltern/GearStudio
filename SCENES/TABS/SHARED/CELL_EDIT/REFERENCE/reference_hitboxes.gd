extends CheckButton

@export var box_parent: Control


func _toggled(toggled_on: bool) -> void:
	box_parent.visible = toggled_on
