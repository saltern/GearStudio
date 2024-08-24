extends TextureRect

@export var sprite_index: SpinBox


func _ready() -> void:
	sprite_index.max_value = SharedData.data.sprites.size() - 1
	sprite_index.value_changed.connect(update_sprite)
	SharedData.changed_palette.connect(update_palette)
	
	update_sprite(0)
	update_palette()


func update_sprite(new_index: int) -> void:
	texture = SharedData.data.sprites[new_index].texture


func update_palette() -> void:
	material.set_shader_parameter("palette", SharedData.get_palette_colors())
