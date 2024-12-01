extends SteppingSpinBox

@onready var sprite_edit: SpriteEdit = owner


func _ready() -> void:
	if not sprite_edit.obj_data.has("palettes"):
		get_parent().queue_free()
		return
	
	max_value = sprite_edit.obj_data["palettes"].size() - 1
	value_changed.connect(sprite_edit.palette_set)
	#sprite_edit.obj_data.palette_selected.connect(external_update_value)


func external_update_value(index: int) -> void:
	call_deferred("set_value_no_signal", index)
