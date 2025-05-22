extends TabContainer

@export var load_dialog_dir: FileDialog
@export var load_dialog_bin: FileDialog
@export var save_as_dialog: FileDialog
@export var session_scene: PackedScene

var waiting_tasks: Dictionary = {}
	

func _ready() -> void:
	GlobalSignals.menu_save.connect(save_resource)
	
	SessionData.tab_closed.connect(on_tab_closed)
	SessionData.load_complete.connect(finished_loading)
	
	load_dialog_dir.dir_selected.connect(load_directory)
	load_dialog_bin.file_selected.connect(load_binary)
	save_as_dialog.file_selected.connect(save_resource)
	tab_changed.connect(on_tab_changed)


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
	Status.set_status(tr("STATUS_LOADING").format({path=path}))
	
	if not Settings.misc_allow_reopen:
		if Opened.path_is_open(path):
			Status.set_status("STATUS_OPEN_ALREADY_OPEN_DIR")
			return
	
	add_task(WorkerThreadPool.add_task(
		SessionData.new_directory_session.bind(path))
	)


func load_binary(path: String) -> void:
	Status.set_status(tr("STATUS_LOADING").format({path=path}))
	
	if not Settings.misc_allow_reopen:
		if Opened.path_is_open(path):
			Status.set_status("STATUS_OPEN_ALREADY_OPEN_BIN")
			return
	
	add_task(WorkerThreadPool.add_task(
		SessionData.new_binary_session.bind(path))
	)


func save_resource(path: String = ""):
	if SessionData.this_session.is_empty():
		Status.set_status("STATUS_SAVE_NOTHING")
		return
	
	match SessionData.get_session_type():
		SessionData.SessionType.DIRECTORY:
			save_directory("")
			
		SessionData.SessionType.BINARY:
			if !path.is_empty():
				if path.get_extension() != "bin":
					path += ".bin"
				
				# For subsequent saves
				SessionData.this_session["path"] = path
				
				var file_name: String = path.get_file()
				get_child(current_tab).base_name = file_name
				rename_tab(current_tab)
			
			save_binary(path)


func save_directory(path: String = ""):
	add_task(WorkerThreadPool.add_task(SessionData.save_directory.bind(path)))


func save_binary(path: String = ""):
	add_task(WorkerThreadPool.add_task(SessionData.save_binary.bind(path)))


func finished_loading(path: String, data: Dictionary) -> void:
	if data["data"].is_empty():
		if data["session_type"] == SessionData.SessionType.DIRECTORY:
			Status.set_status(tr("STATUS_LOAD_DIR_NOTHING").format({path=path}))
		else:
			Status.set_status("STATUS_LOAD_INVALID")
		return
	
	Opened.path_open(path)
	
	var new_tab: Control = session_scene.instantiate()
	new_tab.session_id = get_child_count()
	new_tab.load_tabs(data)
	
	var names: PackedStringArray = get_new_tab_name(path)
	new_tab.base_name = names[0]
	
	add_child(new_tab)
	set_tab_title(get_tab_count() - 1, names[1])
	
	Status.set_status(tr("STATUS_LOAD_COMPLETE").format({path=path}))


func get_new_tab_name(path: String) -> PackedStringArray:
	var base_name: String = path.split("\\")[-1]
	base_name = base_name.split("/")[-1]
	
	var pretty_name: String = tr("TAB_BASE_NAME").format(
		{id=get_child_count(), name=base_name}
	)
	
	return [base_name, pretty_name]


func on_tab_changed(new_tab: int) -> void:
	SessionData.tab_load(new_tab)


func on_tab_closed(index: int) -> void:
	var closed_tab: Node = get_child(index)
	
	remove_child(closed_tab)
	closed_tab.queue_free()
	
	rename_all_tabs()
	SessionData.tab_reset_session_ids.emit()
	
	Opened.path_close(index)


func rename_all_tabs() -> void:
	for tab in get_tab_count():
		rename_tab(tab)


func rename_tab(tab_index: int) -> void:
	var pretty_name: String = tr("TAB_BASE_NAME").format(
		{id=tab_index, name=get_child(tab_index).base_name}
	)
	
	set_tab_title(tab_index, pretty_name)
