extends SteppingSpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	SpriteImport.sprite_placement_finished.connect(update_max_value)
	update_max_value()


func update_max_value() -> void:
	max_value = sprite_edit.obj_data["sprites"].size() - 1
