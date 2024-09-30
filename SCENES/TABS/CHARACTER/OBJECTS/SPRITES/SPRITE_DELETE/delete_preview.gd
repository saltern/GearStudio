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
	var sprite: BinSprite = sprite_edit.obj_data.sprite_get(index)
	
	texture = sprite.texture
	
	material.set_shader_parameter("reindex",
		sprite.bit_depth == 8 or sprite_edit.obj_data.has_palettes())
	
	if sprite_edit.obj_data.has_palettes():
		material.set_shader_parameter(
			"palette", sprite_edit.obj_data.palette_get(0).palette)
	
	else:
		material.set_shader_parameter("palette", sprite.palette)
