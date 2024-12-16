extends PopupMenu

enum ButtonID {
	OPEN_DIR,
	OPEN_BIN,
	SAVE,
	SAVE_AS,
	SEPARATOR_0,
	CLOSE,
	SEPARATOR_1,
	EXIT,
}

const button_names: Dictionary = {
	ButtonID.OPEN_DIR: "FILE_OPEN_DIR",
	ButtonID.OPEN_BIN: "FILE_OPEN_BIN",
	ButtonID.SAVE: "FILE_SAVE",
	ButtonID.SAVE_AS: "FILE_SAVE_AS",
	ButtonID.SEPARATOR_0: "",
	ButtonID.CLOSE: "FILE_CLOSE",
	ButtonID.SEPARATOR_1: "",
	ButtonID.EXIT: "FILE_EXIT",
}

@export var load_dialog_dir: FileDialog
@export var load_dialog_bin: FileDialog
@export var save_as_dialog: FileDialog
@export var overwrite_dialog: ConfirmationDialog


func _ready() -> void:
	for item in button_names:
		if button_names[item] == "":
			add_separator()
			continue
		
		add_item(button_names[item])
			
	id_pressed.connect(menu_clicked)


func menu_clicked(menu_id: int) -> void:
	match menu_id:
		ButtonID.OPEN_DIR:
			load_dialog_dir.current_file = ""
			load_dialog_dir.current_dir = FileMemory.menu_load_directory
			load_dialog_dir.show()
		
		ButtonID.OPEN_BIN:
			load_dialog_bin.current_path = FileMemory.menu_load_binary
			load_dialog_bin.show()
		
		ButtonID.SAVE:
			overwrite_dialog.show()

		ButtonID.SAVE_AS:
			if SessionData.this_session.is_empty():
				Status.set_status("STATUS_SAVE_NOTHING")
				return
			
			var session_type := SessionData.get_session_type()
			if session_type == SessionData.SessionType.DIRECTORY:
				Status.set_status("STATUS_DIRECTORY_CANT_SAVE_AS")
				return
			
			if not FileMemory.menu_save_as.is_empty():
				save_as_dialog.current_dir = FileMemory.menu_save_as.get_base_dir()
				save_as_dialog.current_file = ""
			
			save_as_dialog.show()

		ButtonID.CLOSE:
			SessionData.tab_close()

		ButtonID.EXIT:
			FileMemory.save_memory()
			get_tree().quit()
