extends ItemList

const box_types: Dictionary = {
	1: "Hitbox",
	2: "Hurtbox",
}


func _ready() -> void:
	item_selected.connect(on_item_clicked)
	empty_clicked.connect(on_background_clicked)
	SharedData.selected_box.connect(external_selection)
	SharedData.deselected_boxes.connect(external_clear_selection)
	SharedData.box_editing_toggled.connect(check_enable)


func on_item_clicked(index: int = 0) -> void:
	SharedData.select_box(index)


func on_background_clicked(_pos := Vector2.ZERO, _button: int = 0) -> void:
	SharedData.deselect_boxes()


func external_selection(index: int) -> void:
	select(index)


func external_clear_selection() -> void:
	deselect_all()


func update() -> void:
	clear()
	
	for box in SharedData.data.get_boxes():
		var type: String = "Unknown"
		
		if box.type in box_types:
			type = box_types[box.type]
		
		add_item("Box %02d, Type: %s (%s)" % [item_count, box.type, type])


func check_enable() -> void:
	for item in item_count:
		set_item_disabled(item, !SharedData.box_edits_allowed)
