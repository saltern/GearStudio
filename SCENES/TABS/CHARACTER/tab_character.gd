extends TabContainer

@export var TabObject: PackedScene

var base_name: String = ""


func load_tabs(data: Dictionary) -> void:
	var tabs: PackedStringArray = []
	
	for key in data:
		if not key is String:
			continue
		
		tabs.append(key)
	
	if tabs.has("player"):
		tabs.remove_at(tabs.find("player"))
		tabs.insert(0, "player")
	
	for key in tabs:
		var this_key: Dictionary = data[key]
		
		match this_key["type"]:
			"object":
				var new_object = TabObject.instantiate()
				new_object.name = this_key["data"].name
				add_child(new_object)
			_:
				pass
