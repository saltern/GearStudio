extends PopupMenu

enum ButtonID {
	UNDO,
	REDO,
	ACTION_HISTORY,
	SEPARATOR_0,
	PREFERENCES,
}

const button_names: Dictionary = {
	ButtonID.UNDO: "EDIT_UNDO",
	ButtonID.REDO: "EDIT_REDO",
	ButtonID.ACTION_HISTORY: "EDIT_ACTION_HISTORY",
	ButtonID.SEPARATOR_0: "",
	ButtonID.PREFERENCES: "EDIT_PREFERENCES",
}


func _ready() -> void:
	for item in button_names:
		if button_names[item] == "":
			add_separator()
			continue
		
		add_item(button_names[item])
			
	id_pressed.connect(menu_clicked)


func menu_clicked(menu_id: int) -> void:
	match menu_id:
		ButtonID.UNDO:
			GlobalSignals.menu_undo.emit()
		
		ButtonID.REDO:
			GlobalSignals.menu_redo.emit()

		ButtonID.ACTION_HISTORY:
			Status.set_status("STATUS_ACTION_HISTORY_NO")
		
		ButtonID.PREFERENCES:
			Settings.display_window.emit()
