extends ColorRect


func _ready() -> void:
	Settings.custom_color_status_changed.connect(update_color)
	update_color()


func update_color() -> void:
	color = Settings.custom_color_status
