extends PopupMenu

enum ButtonID {
	LOAD,
	#LOAD_BIN,
	SAVE,
	#SAVE_AS,
	SEPARATOR_0,
	CLOSE,
	SEPARATOR_1,
	EXIT,
}

const button_names: Dictionary = {
	ButtonID.LOAD: "Load...",
	#ButtonID.LOAD_BIN: "Load (binary)...",
	ButtonID.SAVE: "Save",
	#ButtonID.SAVE_AS: "Save as...",
	ButtonID.SEPARATOR_0: "",
	ButtonID.CLOSE: "Close",
	ButtonID.SEPARATOR_1: "",
	ButtonID.EXIT: "Exit",
}

@export var load_dialog_dir: FileDialog
@export var load_dialog_bin: FileDialog


func _ready() -> void:
	for item in button_names:
		if button_names[item] == "":
			add_separator()
			continue
		
		add_item(button_names[item])
			
	id_pressed.connect(menu_clicked)


func menu_clicked(menu_id: int) -> void:
	match menu_id:
		ButtonID.LOAD:
			load_dialog_dir.current_file = ""
			load_dialog_dir.show()
		
		#ButtonID.LOAD_BIN:
			#load_dialog_bin.show()
		
		ButtonID.SAVE:
			GlobalSignals.menu_save.emit()

		#ButtonID.SAVE_AS:
			#Status.set_status("Save as is not currently available.")

		ButtonID.CLOSE:
			SessionData.tab_close()

		ButtonID.EXIT:
			get_tree().quit()
