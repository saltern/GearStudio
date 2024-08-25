extends ItemList

const box_types: Dictionary = {
	1: "Hitbox",
	2: "Hurtbox",
	3: "Region",
	5: "Effect Spawn Point"
}


func external_selection(index: int) -> void:
	select(index)


func external_clear_selection() -> void:
	deselect_all()


func update(boxes: Array[BoxInfo]) -> void:
	clear()
	
	for box in boxes:
		var type_num: int = box.type
		var type: String = "Unknown"
		
		if box.type & 0xFFFF == 3:
			type = box_types[3]
			type_num = 3
			
			var offset_x: String = "%s" % (8 * ((box.type >> 16) & 0xFF))
			var offset_y: String = "%s" % (8 * ((box.type >> 24) & 0xFF))
			
			type += " (%s, %s)" % [offset_x, offset_y]
		
		elif box.type in box_types:
			type = box_types[box.type]
		
		add_item("Box %02d, Type: %s (%s)" % [item_count, type_num, type])


func check_enable(enabled: bool) -> void:
	for item in item_count:
		set_item_disabled(item, !enabled)
