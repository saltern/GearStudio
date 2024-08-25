extends Control

signal box_changed

var obj_state: ObjectEditState


func load_boxes(boxes: Array[BoxInfo]) -> void:
	for box in get_children():
		box.queue_free()
	
	for box in boxes.size():
		var this_box: BoxInfo = boxes[box]
		var new_box := BoxPreview.new()
		
		new_box.obj_state = obj_state
		
		if this_box.type & 0xFFFF == 3:
			new_box.box_type = 3
		
		else:
			new_box.box_type = this_box.type
			
		new_box.box_index = box
		new_box.position = this_box.rect.position
		new_box.size = this_box.rect.size
		new_box.register_changes.connect(on_box_changed)
		
		add_child(new_box)


func on_box_changed(index: int, rect: Rect2i) -> void:
	box_changed.emit(index, rect)


func box_update(box_index: int, box_info: BoxInfo) -> void:
	get_child(box_index).external_update(box_info)
