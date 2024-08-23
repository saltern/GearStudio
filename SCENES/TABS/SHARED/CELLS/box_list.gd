extends ItemList

const box_types: Dictionary = {
	1: "Hitbox",
	2: "Hurtbox",
}

var data: CharacterData


func update() -> void:
	clear()
	
	for box in data.get_boxes():
		var type: String = "Unknown"
		
		if box.type in box_types:
			type = box_types[box.type]
		
		add_item("Box %02d, Type: %s (%s)" % [item_count, box.type, type])
