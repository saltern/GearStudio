extends ColorPickerButton

@export var type: Settings.BoxType


func _ready() -> void:
	color = Settings.box_colors[Settings.BoxType.UNKNOWN]
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.set_box_color(type, new_color)
