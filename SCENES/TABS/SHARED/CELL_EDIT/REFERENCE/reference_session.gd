extends OptionButton

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	SessionData.load_complete.connect(add_session.unbind(1))
	SessionData.tab_closed.connect(update_sessions.unbind(1))
	item_selected.connect(set_session)
	update_sessions()


func add_session(path: String) -> void:
	var session_id: int = SessionData.get_session_count() - 1
	
	var file_name: String = path.get_file()
	add_item("File %s: %s" % [item_count, file_name], session_id)


func update_sessions() -> void:
	clear()
	cell_edit.reference_clear_session()
	
	add_item("None", -2)
	
	if SessionData.sessions.size() < 2:
		return
	
	for session_number in SessionData.get_session_count():
		if session_number == cell_edit.session_id:
			continue
		
		var this_session: Dictionary = SessionData.get_session(session_number)
		var path: String = this_session["path"].get_file()
		
		add_item("File %s: %s" % [session_number, path], session_number)


func set_session(index: int) -> void:
	var id: int = get_item_id(index)
	
	if id < 0:
		cell_edit.reference_clear_session()
		return
	
	cell_edit.reference_set_session(id)
