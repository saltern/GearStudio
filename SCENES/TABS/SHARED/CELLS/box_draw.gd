extends Control

@export var box_list: ItemList
@export var box_offset_x: SpinBox
@export var box_offset_y: SpinBox
@export var box_width: SpinBox
@export var box_height: SpinBox

var data: CharacterData


func load_boxes() -> void:
	for box in get_children():
		box.queue_free()
	
	for box in data.cells[data.cell_index].boxes.size():
		var this_box: BoxInfo = data.cells[data.cell_index].boxes[box]
		
		var new_box := BoxPreview.new()
		new_box.box_type = this_box.type
		new_box.box_index = box
		new_box.position = this_box.rect.position
		new_box.size = this_box.rect.size
		new_box.register_changes.connect(box_changed)
		new_box.box_selected.connect(get_owner().select_box)
		
		add_child(new_box)


func box_changed(index: int, rect: Rect2i) -> void:
	data.cells[data.cell_index].boxes[index].rect = rect
	
	box_offset_x.set_value_no_signal(rect.position.x)
	box_offset_y.set_value_no_signal(rect.position.y)
	box_width.set_value_no_signal(rect.size.x)
	box_height.set_value_no_signal(rect.size.y)


func box_update(box_index: int) -> void:
	get_child(box_index).external_update(
			data.cells[data.cell_index].boxes[box_index])
