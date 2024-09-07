extends SpinBox

@export var sprite_range_start: SpinBox


func _ready() -> void:
	var obj_state := SessionData.object_state_get(get_owner().get_parent().name)
	
	min_value = 0
	max_value = obj_state.sprite_get_count() - 1

	sprite_range_start.value_changed.connect(update_min_value)
	value_changed.connect(on_range_end_changed)


func update_min_value(new_value: int) -> void:
	min_value = new_value


func on_range_end_changed(new_value: int) -> void:
	SpriteExport.export_end_index = new_value
