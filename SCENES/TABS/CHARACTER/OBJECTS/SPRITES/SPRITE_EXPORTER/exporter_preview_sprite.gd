extends TextureRect

@export var sprite_index_spinbox: SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	sprite_index_spinbox.value_changed.connect(update_texture)
	update_texture(0)


func update_texture(sprite_index: int) -> void:
	texture = sprite_edit.sprite_get(sprite_index).texture
