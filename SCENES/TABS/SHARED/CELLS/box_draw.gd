extends Control

signal box_changed

@onready var obj_state := SessionData.object_state_get(
	get_owner().get_parent().name)


func load_boxes(boxes: Array[BoxInfo]) -> void:
	for box in get_children():
		box.queue_free()
	
	for box in boxes.size():
		var this_box: BoxInfo = boxes[box]
		var new_box := BoxPreview.new()
		
		obj_state.box_updated.connect(new_box.external_update)
		obj_state.box_selected.connect(new_box.external_make_active)
		obj_state.boxes_deselected.connect(new_box.external_deselect)
		new_box.box_type = this_box.type & 0xFFFF
		new_box.box_index = box
		new_box.position = this_box.rect.position
		new_box.size = this_box.rect.size
		new_box.register_changes.connect(on_box_changed)
		
		add_child(new_box)


func on_box_changed(index: int, rect: Rect2i) -> void:
	box_changed.emit(index, rect)


func box_update(box_index: int) -> void:
	get_child(box_index).external_update(SessionData.box_get(box_index))
