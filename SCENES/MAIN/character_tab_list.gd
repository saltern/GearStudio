extends TabContainer

@export var load_dialog_dir: FileDialog
@export var load_dialog_bin: FileDialog
@export var character_scene: PackedScene

var waiting_tasks: Array[int] = []


func _ready() -> void:
	GlobalSignals.menu_save.connect(save_character)
	
	SessionData.tab_closed.connect(on_tab_closed)
	SessionData.tab_loading_complete.connect(character_finished_loading)
	
	load_dialog_dir.dir_selected.connect(load_directory)
	load_dialog_bin.file_selected.connect(load_binary)
	tab_changed.connect(on_tab_changed)


func _physics_process(_delta: float) -> void:
	if waiting_tasks.is_empty():
		return
	
	for task in waiting_tasks:
		if WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			waiting_tasks.pop_at(waiting_tasks.find(task))


func load_directory(path: String) -> void:
	Status.set_status("Loading [%s]..." % path)
	
	if not Settings.misc_allow_reopen:
		if Opened.path_is_open(path):
			Status.set_status("Directory already open!")
			return
	
	var task_id := WorkerThreadPool.add_task(SessionData.tab_new.bind(path))
	waiting_tasks.append(task_id)


func load_binary(path: String) -> void:
	Status.set_status("Loading [%s]..." % path)
	
	if not Settings.misc_allow_reopen:
		if Opened.path_is_open(path):
			Status.set_status("File already open!")
			return
	
	var task_id := WorkerThreadPool.add_task(
		SessionData.tab_new_binary.bind(path))
	waiting_tasks.append(task_id)


func save_character():
	var task_id := WorkerThreadPool.add_task(SessionData.save)
	waiting_tasks.append(task_id)


func character_finished_loading(path: String, tabs: PackedStringArray) -> void:
	if tabs.is_empty():
		Status.set_status("No compatible data found at [%s]." % path)
		return
	
	Opened.path_open(path)
	
	var new_character: Control = character_scene.instantiate()
	new_character.load_tabs(tabs)
	
	new_character.base_name = path.split("\\")[-1]
	new_character.base_name = path.split("/")[-1]
	
	var new_name: String = "File %s: %s" % [
		get_child_count(), new_character.base_name]
	
	add_child(new_character)
	set_tab_title(get_tab_count() - 1, new_name)
	
	Status.set_status("Loaded data from [%s]." % path)


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
