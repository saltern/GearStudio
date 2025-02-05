extends MenuButton


func _ready() -> void:
	var test_submenu := PopupMenu.new()	
	get_popup().add_submenu_node_item("Select session", test_submenu)

	SessionData.load_complete.connect(add_session.bind(test_submenu))


func add_session(path: String, _session: Dictionary, submenu: PopupMenu) -> void:
	submenu.add_item(path)
