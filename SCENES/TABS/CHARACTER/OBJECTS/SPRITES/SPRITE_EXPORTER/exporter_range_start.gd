extends SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	min_value = 0
	max_value = sprite_edit.sprite_get_count() - 1

	value_changed.connect(on_range_start_changed)


func on_range_start_changed(new_value: int) -> void:
	SpriteExport.set_export_start_index(new_value)
