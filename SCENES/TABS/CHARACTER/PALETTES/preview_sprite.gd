extends TextureRect

@export var sprite_index: SpinBox

@onready var palette_edit: PaletteEdit = get_owner()
var provider: PaletteProvider


func _ready() -> void:
	provider = palette_edit.get_provider()
	sprite_index.value_changed.connect(on_sprite_changed)
	provider.palette_updated.connect(on_palette_updated)
	
	SessionData.refresh_previews.connect(refresh_preview)
	
	on_sprite_changed(0)


func on_sprite_changed(new_index: int) -> void:
	texture = palette_edit.sprite_get(new_index).texture


func on_palette_updated(palette: PackedByteArray) -> void:
	material.set_shader_parameter("palette", palette)


func refresh_preview(for_id: int) -> void:
	if for_id != palette_edit.session_id:
		print_debug("Palette edit preview refresh session id mismatch")
		return

	var reindex: bool = SessionData.session_get_reindex(palette_edit.session_id)
	print("Reindex: %s" % reindex)

	material.set_shader_parameter("reindex", reindex)
	
	on_sprite_changed(sprite_index.value)
