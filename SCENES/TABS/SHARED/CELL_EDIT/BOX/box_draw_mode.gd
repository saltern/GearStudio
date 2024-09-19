extends Button

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	cell_edit.box_editing_toggled.connect(on_box_editing_toggled)
	toggled.connect(on_draw_mode_toggled)
	disabled = true


func on_box_editing_toggled(enabled: bool) -> void:
	if button_pressed:
		button_pressed = false
		cell_edit.box_set_draw_mode(false)
	
	disabled = !enabled


func on_draw_mode_toggled(enabled: bool) -> void:
	cell_edit.box_deselect_all()
	cell_edit.box_set_draw_mode(enabled)
