extends SteppingSpinBox

@export var delete_from: SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	delete_from.value_changed.connect(update_min_value)
	SpriteImport.sprite_placement_finished.connect(update_max_value)
	update_max_value()


func update_min_value(new_min_value: int) -> void:
	min_value = new_min_value


func update_max_value() -> void:
	max_value = sprite_edit.obj_data["sprites"].size() - 1
