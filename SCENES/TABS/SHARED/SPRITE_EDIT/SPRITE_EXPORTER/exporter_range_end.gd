extends SpinBox

@export var sprite_range_start: SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	sprite_range_start.value_changed.connect(update_min_value)
	value_changed.connect(on_range_end_changed)
	sprite_edit.sprites_deleted.connect(update_range)
	SpriteImport.sprite_placement_finished.connect(update_range)
	update_range()


func update_min_value(new_value: int) -> void:
	min_value = new_value


func on_range_end_changed(new_value: int) -> void:
	SpriteExport.export_end_index = new_value


func update_range() -> void:
	min_value = 0
	max_value = sprite_edit.sprite_get_count() - 1
