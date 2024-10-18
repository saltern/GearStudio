extends ColorRect


func _ready() -> void:
	Settings.guide_color_changed.connect(update_color)
	update_color()
	hide()


func update_color() -> void:
	color = Settings.cell_guide
