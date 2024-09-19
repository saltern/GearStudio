extends TabContainer

@export var TabObject: PackedScene
@export var TabPalettes: PackedScene

var base_name: String = ""


func _ready() -> void:
	tab_changed.connect(on_tab_changed)
	on_tab_changed(current_tab)


func load_tabs(tabs: PackedStringArray) -> void:
	if tabs.has("player"):
		tabs.remove_at(tabs.find("player"))
		tabs.insert(0, "player")
	
	for tab in tabs:
		if tab == "palettes":
			add_child(TabPalettes.instantiate())
		
		else:
			var new_object = TabObject.instantiate()
			new_object.name = tab
			add_child(new_object)


func on_tab_changed(new_tab: int) -> void:
	if get_tab_title(new_tab) != "palettes":
		var tab_name: String = get_tab_title(new_tab)

	else:
		SessionData.this_tab["current_object"] = "palettes"
