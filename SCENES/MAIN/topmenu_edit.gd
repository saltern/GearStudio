extends PopupMenu

enum ButtonID {
	UNDO,
	REDO,
	ACTION_HISTORY,
	SEPARATOR_0,
	PREFERENCES,
}

const button_names: Dictionary = {
	ButtonID.UNDO: "Undo",
	ButtonID.REDO: "Redo",
	ButtonID.ACTION_HISTORY: "Action History...",
	ButtonID.SEPARATOR_0: "",
	ButtonID.PREFERENCES: "Preferences...",
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
			SessionData.menu_undo()
		
		ButtonID.REDO:
			SessionData.menu_redo()

		ButtonID.ACTION_HISTORY:
			Status.set_status("The Action History is not currently available.")
		
		ButtonID.PREFERENCES:
			Status.set_status("The Preferences menu is not currently available.")
