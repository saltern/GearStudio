extends SpinBox


func _ready() -> void:
	SpriteImport.sprite_import_finished.connect(update_max_value)
	update_max_value()
	
	value_changed.connect(SpriteImport.set_insert_position)


func update_max_value() -> void:
	var obj_state: ObjectEditState = SessionData.object_state_get(
		get_owner().get_parent().name)
	
	max_value = obj_state.sprite_get_count()
