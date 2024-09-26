extends CheckButton

@export var control_index: HBoxContainer
@export var control_override: CheckButton
@export var control_alpha: HBoxContainer


func _ready() -> void:
	toggled.connect(on_palette_include_toggled)
	on_palette_include_toggled(button_pressed)


func on_palette_include_toggled(enabled: bool) -> void:
	SpriteExport.palette_include = enabled
	control_index.visible = enabled
	control_override.visible = enabled
	control_alpha.visible = enabled
