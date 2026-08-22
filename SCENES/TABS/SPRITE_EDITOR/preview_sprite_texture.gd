extends TextureRect

@export var control_opaque_bg: CheckButton

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	editor.session.palette_changed.connect(load_palette.unbind(1))
	editor.preview_outdated.connect(update)
	editor.sprite_changed.connect(update.unbind(1))
	control_opaque_bg.toggled.connect(on_opaque_bg_toggled)
	
	update()


func update() -> void:
	texture = editor.this_sprite.get_texture()
	load_palette()


func load_palette() -> void:
	(material as ShaderMaterial).set_shader_parameter(
		"palette", editor.get_current_palette()
	)


func on_opaque_bg_toggled(enabled: bool) -> void:
	(material as ShaderMaterial).set_shader_parameter(
		"opaque_bg", enabled
	)
