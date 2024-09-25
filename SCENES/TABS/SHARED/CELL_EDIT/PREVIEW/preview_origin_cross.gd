extends Control


func _ready() -> void:
	Settings.draw_origin_changed.connect(update_visibility)
	update_visibility()


func update_visibility() -> void:
	visible = Settings.cell_draw_origin
