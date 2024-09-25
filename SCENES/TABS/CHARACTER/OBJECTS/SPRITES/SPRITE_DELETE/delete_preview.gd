extends TextureRect

@export var sprite_index: SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	sprite_index.value_changed.connect(update_sprite)
	update_sprite(0)


func update_sprite(index: int) -> void:
	texture = sprite_edit.obj_data.sprites[index].texture
