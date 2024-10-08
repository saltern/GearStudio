extends ColorRect

var draw_bounds: bool = true
var bounds: Rect2i

@export var display_toggle: CheckButton

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	color = Settings.sprite_color_bounds
	Settings.sprite_bounds_color_changed.connect(update_color)
	display_toggle.toggled.connect(update_mode)


func update_color() -> void:
	color = Settings.sprite_color_bounds


func update_mode(enabled: bool) -> void:
	visible = enabled
