extends MenuButton

@onready var cell_edit: CellEdit = owner

var session_submenu: PopupMenu = PopupMenu.new()
var object_submenu: PopupMenu = PopupMenu.new()


var session: Dictionary = {}
#var object: int = 0


func _ready() -> void:
	get_popup().add_submenu_node_item("Session #", session_submenu)
	get_popup().add_submenu_node_item("Object #", object_submenu)

	SessionData.load_complete.connect(update_sessions.unbind(2))
	SessionData.tab_closed.connect(update_sessions.unbind(1))
	
	update_sessions()
	
	session_submenu.id_pressed.connect(select_session)
	object_submenu.id_pressed.connect(select_object)


func update_sessions() -> void:
	for session_number in SessionData.sessions.size():
		if session_number == cell_edit.session_id:
			continue
		
		var this_session: Dictionary = SessionData.get_session(session_number)
		var path: String = this_session["path"].get_file()
		
		session_submenu.add_item(
			"File #%s: %s" % [session_number, path], session_number
		)


func select_session(id: int) -> void:
	cell_edit.ref_data = {}
	
	session = SessionData.get_session(id)
		
	object_submenu.clear()
	
	for object in session["data"].size():
		object_submenu.add_item("Object #%s" % object)


func select_object(id: int) -> void:
	cell_edit.ref_data = session["data"][id]
