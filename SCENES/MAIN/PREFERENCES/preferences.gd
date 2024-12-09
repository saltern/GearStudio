extends Window

@export var save_button: Button
@export var active: bool = true


func _ready() -> void:
	if active:
		Settings.display_window.connect(display)
	close_requested.connect(close)
	save_button.pressed.connect(close)


func display() -> void:
	show()
	grab_focus()


func close() -> void:
	hide()
	if Settings.save_config():
		Status.set_status("STATUS_PREFERENCES_SAVED")
	else:
		Status.set_status("STATUS_PREFERENCES_SAVE_ERROR")
