extends SteppingSpinBox

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	update_max_value()
	SpriteImport.sprite_placement_finished.connect(update_max_value)


func update_max_value() -> void:
	max_value = cell_edit.obj_data.sprites.size() - 1
