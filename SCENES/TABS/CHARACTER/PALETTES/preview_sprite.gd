extends TextureRect

@export var sprite_index: SpinBox

@onready var palette_edit: PaletteEdit = get_owner()


func _ready() -> void:
	sprite_index.max_value = palette_edit.sprite_get_count() - 1
	sprite_index.value_changed.connect(on_sprite_changed)
	palette_edit.palette_updated.connect(on_palette_updated)
	
	on_sprite_changed(0)
	on_palette_updated(palette_edit.this_palette)


func on_sprite_changed(new_index: int) -> void:
	texture = palette_edit.sprite_get(new_index).texture


func on_palette_updated(new_palette: BinPalette) -> void:
	material.set_shader_parameter("palette", new_palette.palette)
