extends VBoxContainer

@export var TabObject: PackedScene
@export var TabPalettes: PackedScene

@export var tab_container: TabContainer

var base_name: String = ""


func _ready() -> void:
	tab_container.tab_changed.connect(on_tab_changed)
	on_tab_changed(tab_container.current_tab)


func load_tabs(tabs: PackedStringArray) -> void:
	if tabs.has("player"):
		tabs.remove_at(tabs.find("player"))
		tabs.insert(0, "player")
	
	for tab in tabs:
		if tab == "palettes":
			$objects.add_child(TabPalettes.instantiate())
		
		else:
			var new_object = TabObject.instantiate()
			new_object.name = tab
			$objects.add_child(new_object)
	
	


func on_tab_changed(new_tab: int) -> void:
	if tab_container.get_tab_title(new_tab) != "palettes":
		var tab_name: String = tab_container.get_tab_title(new_tab)
		SessionData.object_state_load(tab_name)

	else:
		SessionData.this_tab["current_object"] = "palettes"
