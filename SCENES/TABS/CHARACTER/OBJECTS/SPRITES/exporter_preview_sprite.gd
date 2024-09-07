extends TextureRect

@export var sprite_index_spinbox: SpinBox

var obj_state: ObjectEditState


func _ready() -> void:
	obj_state = SessionData.object_state_get(get_owner().get_parent().name)
	sprite_index_spinbox.value_changed.connect(update_texture)
	update_texture(0)


func update_texture(sprite_index: int) -> void:
	texture = obj_state.sprite_get(sprite_index).texture
