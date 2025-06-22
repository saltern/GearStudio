extends Control

var texture: ImageTexture


func _ready() -> void:
	Settings.draw_origin_changed.connect(update_visibility)
	Settings.origin_type_changed.connect(update_visibility)
	update_visibility()


func _draw() -> void:
	texture = Settings.get_origin_texture()
	var x: float = - floor(texture.get_width() / 2)
	var y: float = - floor(texture.get_height() / 2)
	draw_texture(texture, Vector2(x, y))


func update_visibility() -> void:
	visible = Settings.cell_draw_origin
	queue_redraw()
