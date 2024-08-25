extends VBoxContainer

@export var TabObject: PackedScene
@export var TabPalettes: PackedScene

@export var tab_container: TabContainer


func _ready() -> void:
	tab_container.tab_changed.connect(on_tab_changed)


func load_from_path(path: String) -> void:
	var tabs: PackedStringArray = SessionData.new_tab(path)
	
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
		SessionData.load_object_state(tab_name)
