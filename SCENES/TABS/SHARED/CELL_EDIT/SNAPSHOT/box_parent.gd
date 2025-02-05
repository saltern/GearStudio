extends Control

@warning_ignore("unused_signal")
signal box_changed

@export var draw_offset: Vector2i = Vector2i.ZERO
@export var cell_index: SteppingSpinBox

var obj_data: Dictionary

@onready var cell_edit: CellEdit = owner


func _process(_delta: float) -> void:
	queue_redraw()


func _draw():
	# Using four separate draw_rect()s instead of just one
	# as drawing unfilled boxes is off by a pixel or two
	
	for box in cell_edit.cell_get(cell_index.value).boxes:
		# Don't draw cutout boxes
		if box.box_type in [3, 6]:
			continue
		
		var color := Settings.box_colors[box.box_type]
		
		var top: float = box.y_offset + draw_offset.y
		var left: float = box.x_offset + draw_offset.x
		var right: float = (box.x_offset + box.width) - Settings.box_thickness
		right += draw_offset.x
		
		var bottom: float = (box.y_offset + box.height) - Settings.box_thickness
		bottom += draw_offset.y
		
		var horz: float = box.width
		var vert: float = box.height
		
		# Upper
		draw_rect(Rect2(
				Vector2(left, top), Vector2i(horz, Settings.box_thickness)
			), color
		)
		
		# Left
		draw_rect(Rect2(
				Vector2(left, top), Vector2i(Settings.box_thickness, vert)
			), color
		)
		
		# Lower
		draw_rect(Rect2(
				Vector2(left, bottom), Vector2i(horz, Settings.box_thickness)
			), color
		)
		
		# Right
		draw_rect(Rect2(
				Vector2(right, top), Vector2i(Settings.box_thickness, vert)
			), color
		)
