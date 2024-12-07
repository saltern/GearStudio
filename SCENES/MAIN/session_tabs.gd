extends TabContainer

@export var load_dialog_dir: FileDialog
@export var load_dialog_bin: FileDialog
@export var save_as_dialog: FileDialog
@export var character_scene: PackedScene

var waiting_tasks: Dictionary = {}


func _ready() -> void:
	GlobalSignals.menu_save.connect(save_resource)
	
	SessionData.tab_closed.connect(on_tab_closed)
	SessionData.load_complete.connect(finished_loading)
	
	load_dialog_dir.dir_selected.connect(load_directory)
	load_dialog_bin.file_selected.connect(load_binary)
	save_as_dialog.file_selected.connect(save_resource)
	tab_changed.connect(on_tab_changed)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.keycode:
			KEY_F:
				var data: Dictionary = {
					0: {
						"type": "sprite",
						"sprites": [BinSprite.new()],
					},
				}
				
				var new_tab: Control = character_scene.instantiate()
				new_tab.load_tabs(data)
				
				add_child(new_tab)


func _physics_process(_delta: float) -> void:
	if waiting_tasks.is_empty():
		set_physics_process(false)
	
	for task in waiting_tasks:
		if WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			waiting_tasks.erase(task)


func add_task(task_id: int) -> void:
	waiting_tasks[task_id] = 0
	set_physics_process(true)


func load_directory(path: String) -> void:
	Status.set_status("Loading [%s]..." % path)
	
	if not Settings.misc_allow_reopen:
		if Opened.path_is_open(path):
			Status.set_status("Directory already open!")
			return
	
	add_task(WorkerThreadPool.add_task(
		SessionData.new_directory_session.bind(path))
	)


func load_binary(path: String) -> void:
	Status.set_status("Loading [%s]..." % path)
	
	if not Settings.misc_allow_reopen:
		if Opened.path_is_open(path):
			Status.set_status("File already open!")
			return
	
	add_task(WorkerThreadPool.add_task(
		SessionData.new_binary_session.bind(path))
	)


func save_resource(path: String = ""):
	if SessionData.this_session.is_empty():
		Status.set_status("Nothing to save.")
		return
	
	match SessionData.get_session_type():
		SessionData.SessionType.DIRECTORY:
			save_directory(path)
		SessionData.SessionType.BINARY:
			save_binary(path)


func save_directory(path: String = ""):
	add_task(WorkerThreadPool.add_task(SessionData.save_directory.bind(path)))


func save_binary(path: String = ""):
	add_task(WorkerThreadPool.add_task(SessionData.save_binary.bind(path)))


func finished_loading(path: String, data: Dictionary) -> void:
	if data.is_empty():
		Status.set_status("Unable to load, file invalid or unsupported.")
		return
	
	Opened.path_open(path)
	
	var new_tab: Control = character_scene.instantiate()
	new_tab.session_id = get_child_count()
	new_tab.load_tabs(data)
	
	var names: PackedStringArray = get_new_tab_name(path)
	new_tab.base_name = names[0]
	
	add_child(new_tab)
	set_tab_title(get_tab_count() - 1, names[1])
	
	Status.set_status("Loaded data from [%s]." % path)


func get_new_tab_name(path: String) -> PackedStringArray:
	var base_name: String = path.split("\\")[-1]
	base_name = base_name.split("/")[-1]
	
	var pretty_name: String = "File %s: %s" % [
		get_child_count(), base_name]
	
	return [base_name, pretty_name]


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
