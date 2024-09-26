extends TextureRect


func _ready() -> void:
	Settings.custom_color_bg_b_changed.connect(update_color)
	update_color()


func update_color() -> void:
	modulate = Settings.custom_color_bg_b
