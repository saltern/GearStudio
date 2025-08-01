extends Window

@export var item_list: ItemList


func _ready() -> void:
	ActionHistory.undo_redo_changed.connect(generate_list)
	ActionHistory.version_changed.connect(update_list)
	ActionHistory.show_window.connect(show)
	item_list.item_clicked.connect(on_item_clicked)
	close_requested.connect(hide)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	
	if event.is_echo():
		return
	
	if event.keycode == KEY_ESCAPE:
		hide()


func generate_list() -> void:
	item_list.clear()
	item_list.add_item("ACTION_HISTORY_FILE_OPENED")
	
	for action in ActionHistory.get_action_count():
		item_list.add_item(ActionHistory.get_action(action))
	
	item_list.select(ActionHistory.get_version())


func update_list() -> void:
	if get_max_index() >= ActionHistory.get_action_count():
		generate_list()
		
	elif get_max_index() < ActionHistory.get_action_count():
		item_list.add_item(ActionHistory.get_most_recent_action())
	
	item_list.select(ActionHistory.get_version())


func on_item_clicked(index: int, _pos: Vector2, mouse_button: int) -> void:
	# Disallow selecting with mouse wheel and extra buttons
	if mouse_button > 2:
		return
	
	ActionHistory.set_version(index)


func get_max_index() -> int:
	return item_list.item_count - 1
