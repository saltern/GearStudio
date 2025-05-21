extends SteppingSpinBox

@export var reference_node: CanvasGroup


func _ready() -> void:
	min_value = 0
	max_value = 255
	value = 255
	value_changed.connect(update)


func update(_new_value: float) -> void:
	reference_node.self_modulate.a8 = value
