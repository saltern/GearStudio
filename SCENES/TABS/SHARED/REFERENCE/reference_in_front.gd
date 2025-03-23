extends CheckButton

@export var reference_parent: CanvasGroup


func _toggled(toggled_on: bool) -> void:
	reference_parent.z_index = 2 * (toggled_on as int)
