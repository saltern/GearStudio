extends SpinBox


func _ready() -> void:
	var obj_state := SessionData.object_state_get(get_owner().get_parent().name)
	
	min_value = 0
	max_value = obj_state.sprite_get_count() - 1

	value_changed.connect(on_range_start_changed)


func on_range_start_changed(new_value: int) -> void:
	SpriteExport.export_start_index = new_value
