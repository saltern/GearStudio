extends SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	SpriteImport.sprite_placement_finished.connect(update_max_value)
	update_max_value()
	
	value_changed.connect(SpriteImport.set_insert_position)


func update_max_value() -> void:
	max_value = sprite_edit.sprite_get_count()
