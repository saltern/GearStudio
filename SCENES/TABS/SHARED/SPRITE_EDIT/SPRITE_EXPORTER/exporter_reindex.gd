extends CheckButton

@export var palette_material: ShaderMaterial


func _ready() -> void:
	toggled.connect(on_toggle)
	on_toggle(button_pressed)


func on_toggle(enabled: bool) -> void:
	palette_material.set_shader_parameter("reindex", enabled)
