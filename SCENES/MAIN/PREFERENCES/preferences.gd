extends Window

@export var save_button: Button


func _ready() -> void:
	Settings.display_window.connect(display)
	close_requested.connect(close)
	save_button.pressed.connect(close)


func display() -> void:
	show()
	grab_focus()


func close() -> void:
	hide()
	if Settings.save_config():
		Status.set_status("Saved preferences.")
	else:
		Status.set_status("Could not save preferences!")
