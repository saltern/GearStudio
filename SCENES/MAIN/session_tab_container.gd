extends TabContainer

@export var load_dialog_dir: FileDialog
@export var load_dialog_bin: FileDialog
@export var save_as_dialog: FileDialog
@export var session_scene: PackedScene

var task_id: int
	

func _ready() -> void:
	GlobalSignals.menu_save.connect(save_resource)
	
	SessionData.tab_closed.connect(on_tab_closed)
	SessionData.load_complete.connect(create_tab)
	
	load_dialog_dir.dir_selected.connect(load_directory)
	load_dialog_bin.file_selected.connect(load_binary)
	save_as_dialog.file_selected.connect(save_resource)
	tab_changed.connect(on_tab_changed)
	
	get_tree().get_root().files_dropped.connect(on_files_dropped)


func on_files_dropped(files: PackedStringArray) -> void:
	for file: String in files:
		load_binary(file)


func load_directory(path: String) -> void:
	Status.set_status(tr("STATUS_LOADING").format({path=path}))
	
	if not Settings.misc_allow_reopen:
		if Opened.path_is_open(path):
			Status.set_status("STATUS_OPEN_ALREADY_OPEN_DIR")
			return
	
	WorkerThreadPool.add_task(SessionData.new_directory_session.bind(path))


func load_binary(path: String) -> void:
	Status.set_status(tr("STATUS_LOADING").format({path=path}))
	
	if not Settings.misc_allow_reopen:
		if Opened.path_is_open(path):
			Status.set_status("STATUS_OPEN_ALREADY_OPEN_BIN")
			return
	
	WorkerThreadPool.add_task(SessionData.new_binary_session.bind(path))


func save_resource(path: String = ""):
	if SessionData.this_session == null:
		Status.set_status("STATUS_SAVE_NOTHING")
		return
	
	match SessionData.get_session_type():
		Session.Type.DIRECTORY:
			save_directory("")
			
		Session.Type.BINARY:
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
	WorkerThreadPool.add_task(SessionData.save_directory.bind(path))


func save_binary(path: String = ""):
	WorkerThreadPool.add_task(SessionData.save_binary.bind(path))


func create_tab(session: Session) -> void:
	if session.get_object_count() == 0:
		if session.type == Session.Type.DIRECTORY:
			Status.set_status(tr("STATUS_LOAD_DIR_NOTHING").format({path=session.path}))
		else:
			Status.set_status("STATUS_LOAD_INVALID")
		return
	
	Opened.path_open(session.path)
	
	var new_tab: Control = session_scene.instantiate()
	new_tab.initialize(session)
	
	var names: PackedStringArray = get_new_tab_name(session.path)
	new_tab.base_name = names[0]
	
	add_child(new_tab)
	set_tab_title(get_tab_count() - 1, names[1])
	
	GlobalSignals.progress_finish()
	Status.set_status(tr("STATUS_LOAD_COMPLETE").format({path=session.path}))
	#GlobalSignals.editors_created.emit()


func get_new_tab_name(path: String) -> PackedStringArray:
	var base_name: String = path.get_file()
	
	#var pretty_name: String = tr("TAB_BASE_NAME").format(
		#{id=get_child_count(), name=base_name}
	#)
	
	return [base_name, base_name]


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
