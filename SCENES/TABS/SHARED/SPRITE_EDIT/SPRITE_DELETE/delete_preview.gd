extends TextureRect

@export var sprite_index: SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	SpriteImport.sprite_placement_finished.connect(on_sprites_changed)
	sprite_index.value_changed.connect(update_sprite)
	update_sprite(0)


func on_sprites_changed() -> void:
	update_sprite(sprite_index.value)


func update_sprite(index: int) -> void:
	var sprite: BinSprite = sprite_edit.obj_data["sprites"][index]
	
	texture = sprite.texture
	
	material.set_shader_parameter("reindex",
		sprite.bit_depth == 8 or sprite_edit.obj_data.has("palettes"))
	
	if sprite_edit.obj_data.has("palettes"):
		material.set_shader_parameter(
			"palette", sprite_edit.obj_data["palettes"][0].palette)
	
	else:
		material.set_shader_parameter("palette", sprite.palette)
