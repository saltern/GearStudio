extends SteppingSpinBox

@export var range_start: SteppingSpinBox

@onready var sprite_edit: SpriteEdit = owner


func _ready() -> void:
	var object: Dictionary = sprite_edit.obj_data
	max_value = object.sprites.size() - 1
	
	if range_start:
		range_start.value_changed.connect(on_minimum_changed)


func on_minimum_changed(new_minimum: int) -> void:
	min_value = new_minimum
