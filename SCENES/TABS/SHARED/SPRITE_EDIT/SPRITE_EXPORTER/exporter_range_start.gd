extends SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	value_changed.connect(on_range_start_changed)
	SpriteImport.sprite_placement_finished.connect(update_range)
	update_range()


func on_range_start_changed(new_value: int) -> void:
	SpriteExport.set_export_start_index(new_value)


func update_range() -> void:
	min_value = 0
	max_value = sprite_edit.sprite_get_count() - 1
