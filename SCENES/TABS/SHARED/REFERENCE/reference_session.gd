extends OptionButton

@onready var ref_handler: ReferenceHandler = owner.ref_handler


func _ready() -> void:
	SessionData.load_complete.connect(add_session.unbind(1))
	SessionData.tab_closed.connect(update_sessions.unbind(1))
	item_selected.connect(set_session)
	update_sessions()
	
	Settings.language_changed.connect(on_language_changed)


func get_entry_name(index: int) -> String:
	var this_session: Dictionary = SessionData.get_session(index)
	var file_name: String = this_session["path"].get_file()
	
	return tr("REFERENCE_SESSION_ENTRY").format({
		"index": index, "name": file_name
	})


func on_language_changed() -> void:
	for item in range(1, item_count):
		set_item_text(item, get_entry_name(item))


func add_session(path: String) -> void:
	var session_id: int = SessionData.get_session_count() - 1
	add_item(get_entry_name(item_count), session_id)


func update_sessions() -> void:
	clear()
	ref_handler.reference_clear_session()
	
	add_item("REFERENCE_SESSION_NONE", -2)
	
	if SessionData.sessions.size() < 2:
		return
	
	for session_number in SessionData.get_session_count():
		if session_number == owner.session_id:
			continue
		
		add_item(get_entry_name(session_number), session_number)


func set_session(index: int) -> void:
	var id: int = get_item_id(index)
	
	if id < 0:
		ref_handler.reference_clear_session()
		return
	
	ref_handler.reference_set_session(id)
