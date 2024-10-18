extends TabContainer

@export var TabObject: PackedScene

var base_name: String = ""


func load_tabs(tabs: PackedStringArray) -> void:
	if tabs.has("player"):
		tabs.remove_at(tabs.find("player"))
		tabs.insert(0, "player")
	
	for tab in tabs:
		var new_object = TabObject.instantiate()
		new_object.name = tab
		add_child(new_object)
