extends CheckButton

@export var reference: CanvasGroup


func _toggled(toggled_on: bool) -> void:
	reference.self_modulate.a8 = 192 if toggled_on else 255
