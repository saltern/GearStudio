extends TabContainer

@export var load_dialog: FileDialog
@export var character_scene: PackedScene


func _ready() -> void:
	SessionData.tab_closed.connect(on_tab_closed)
	
	load_dialog.dir_selected.connect(load_character)
	tab_changed.connect(on_tab_changed)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_undo"):
		SessionData.undo()


func load_character(path: String) -> void:
	Status.set_status("Loading character from %s..." % path)
	
	if not Settings.misc_allow_reopen:
		if Opened.path_is_open(path):
			Status.set_status("Directory already open!")
			return
	
	Opened.path_open(path)
	
	var tabs: PackedStringArray = SessionData.tab_new(path)
	
	if tabs.is_empty():
		Status.set_status("No compatible data found at [%s]." % path)
		return
	
	var new_character: Control = character_scene.instantiate()
	new_character.load_tabs(tabs)
	
	new_character.base_name = path.split("\\")[-1]
	
	var new_name: String = "File %s: %s" % [
		get_child_count(), new_character.base_name]
	
	add_child(new_character)
	set_tab_title(get_tab_count() - 1, new_name)
	
	Status.set_status("Loaded character from [%s]." % path)


func on_tab_changed(new_tab: int) -> void:
	SessionData.tab_load(new_tab)


func on_tab_closed(index: int) -> void:
	get_child(index).queue_free()
	rename_all_tabs(index)
	Opened.path_close(index)


func rename_all_tabs(skip_index: int) -> void:
	var number: int = 0
	
	for tab in get_tab_count():
		if tab == skip_index:
			continue
		
		set_tab_title(tab, "File %s: %s" % [
			number, get_child(tab).base_name])
		
		number += 1
