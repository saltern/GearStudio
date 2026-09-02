extends TextureRect

@export var pal_helper: PaletteEditorHelper
@export var control_opaque_bg: CheckButton
@export var control_pal_selection: Control

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	editor.session.palette_changed.connect(load_palette.unbind(1))
	editor.preview_outdated.connect(update)
	#editor.sprite_changed.connect(update.unbind(1))
	pal_helper.sprite_updated.connect(update)
	control_opaque_bg.toggled.connect(on_opaque_bg_toggled)
	control_pal_selection.selection_changed.connect(on_selection_changed)
	
	update()


func update() -> void:
	texture = editor.this_sprite.get_texture()
	load_palette()


func load_palette() -> void:
	(material as ShaderMaterial).set_shader_parameter(
		"palette", editor.get_current_palette()
	)


func on_selection_changed() -> void:
	(material as ShaderMaterial).set_shader_parameter(
		"hover_index", control_pal_selection.hover
	)
	
	(material as ShaderMaterial).set_shader_parameter(
		"selecting_min", control_pal_selection.selecting_min
	)
	
	(material as ShaderMaterial).set_shader_parameter(
		"selecting_max", control_pal_selection.selecting_max
	)


func on_opaque_bg_toggled(enabled: bool) -> void:
	(material as ShaderMaterial).set_shader_parameter(
		"opaque_bg", enabled
	)
