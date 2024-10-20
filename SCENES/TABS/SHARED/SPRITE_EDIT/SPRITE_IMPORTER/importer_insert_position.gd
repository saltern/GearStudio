extends SteppingSpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	SpriteImport.sprite_placement_finished.connect(update_max_value)
	update_max_value()
	
	value_changed.connect(update)
	visibility_changed.connect(on_display)


func on_display() -> void:
	if visible:
		update(value)


func update(new_value: int) -> void:
	SpriteImport.set_insert_position(new_value)


func update_max_value() -> void:
	max_value = sprite_edit.sprite_get_count()
