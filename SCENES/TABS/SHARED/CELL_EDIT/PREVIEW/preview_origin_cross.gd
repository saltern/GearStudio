extends Control


func _ready() -> void:
	Settings.draw_origin_changed.connect(update_visibility)
	Settings.origin_type_changed.connect(update_visibility)
	update_visibility()


func _draw() -> void:
	match Settings.cell_origin_type:
		0:	# BG
			draw_rect(Rect2(-1, -21, 3, 43), Color.BLACK)
			draw_rect(Rect2(-21, -1, 43, 3), Color.BLACK)
			draw_solid_cross()
		1:	# BG
			draw_rect(Rect2(-1, -21, 3, 17), Color.BLACK)
			draw_rect(Rect2(-1, 5, 3, 17), Color.BLACK)
			draw_rect(Rect2(-21, -1, 17, 3), Color.BLACK)
			draw_rect(Rect2(5, -1, 17, 3), Color.BLACK)
			draw_crosshair()
		2:	# No BG necessary here
			pass
			draw_solid_cross()
		3:
			draw_rect(Rect2(-5, 0, 11, 1), Color.BLACK)
			draw_rect(Rect2(0, -5, 1, 11), Color.BLACK)
			draw_crosshair()
		_:
			draw_crosshair()


func draw_solid_cross() -> void:
	draw_rect(Rect2(0, -20, 1, 41), Color.WHITE)
	draw_rect(Rect2(-20, 0, 41, 1), Color.WHITE)


func draw_crosshair() -> void:
	draw_rect(Rect2(0, -20, 1, 15), Color.WHITE)
	draw_rect(Rect2(0, 6, 1, 15), Color.WHITE)
	draw_rect(Rect2(-20, 0, 15, 1), Color.WHITE)
	draw_rect(Rect2(6, 0, 15, 1), Color.WHITE)


func update_visibility() -> void:
	visible = Settings.cell_draw_origin
	queue_redraw()
