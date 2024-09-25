extends TextureRect


func _ready() -> void:
	Settings.custom_bg_color_b_changed.connect(update_color)
	update_color()


func update_color() -> void:
	modulate = Settings.custom_color_bg_b
