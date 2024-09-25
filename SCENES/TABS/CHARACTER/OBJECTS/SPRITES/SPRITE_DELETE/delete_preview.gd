extends TextureRect

@export var sprite_index: SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	sprite_edit.sprites_deleted.connect(on_sprites_changed)
	SpriteImport.sprite_placement_finished.connect(on_sprites_changed)
	sprite_index.value_changed.connect(update_sprite)
	update_sprite(0)


func on_sprites_changed() -> void:
	update_sprite(sprite_index.value)


func update_sprite(index: int) -> void:
	texture = sprite_edit.obj_data.sprites[index].texture
	material.set_shader_parameter(
		"palette", sprite_edit.provider.palette_get_colors_fallback())
