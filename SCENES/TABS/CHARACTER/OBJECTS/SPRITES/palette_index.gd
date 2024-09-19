extends SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	sprite_edit.pal_state.changed_palette.connect(external_change_palette)
	value_changed.connect(sprite_edit.palette_set)


func external_change_palette(index: int) -> void:
	call_deferred("set_value_no_signal", index)
