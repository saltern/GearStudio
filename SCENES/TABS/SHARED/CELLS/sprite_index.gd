extends SpinBox


func _ready() -> void:	
	var obj_state: ObjectEditState = SessionData.object_state_get(
		get_owner().get_parent().name)
	
	max_value = obj_state.data.sprites.size() - 1
	value_changed.connect(SessionData.sprite_set_index)
