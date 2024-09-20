extends TextureRect

@export var sprite_index: SpinBox

@onready var palette_edit: PaletteEdit = get_owner()
var provider: PaletteProvider


func _ready() -> void:
	provider = palette_edit.get_provider()
	
	sprite_index.max_value = palette_edit.sprite_get_count() - 1
	sprite_index.value_changed.connect(on_sprite_changed)
	provider.palette_updated.connect(on_palette_updated)
	
	on_sprite_changed(0)
	#on_palette_updated(palette_edit.this_palette)


func on_sprite_changed(new_index: int) -> void:
	texture = palette_edit.sprite_get(new_index).texture


func on_palette_updated(palette: PackedByteArray) -> void:
	material.set_shader_parameter("palette", palette)
