extends TextureRect

@export var main_window: Window
@export var sprite_index: SteppingSpinBox

@onready var sprite_edit: SpriteEdit = owner


func _ready() -> void:
	sprite_index.value_changed.connect(update_preview.unbind(1))
	main_window.palette_changed.connect(update_preview)


func update_preview() -> void:
	var sprite: BinSprite = sprite_edit.obj_data.sprites[sprite_index.value]
	texture = sprite.texture
	material.set_shader_parameter("reindex", sprite.bit_depth == 8)
	material.set_shader_parameter("palette", main_window.palette.palette)
