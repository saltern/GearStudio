extends Window

@export var export_path_dialog: FileDialog


func _ready() -> void:
	title = "Export '%s' sprites..." % get_owner().get_parent().name
	visibility_changed.connect(display_window)
	close_requested.connect(hide)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not event is InputEventKey:
		return
	if not event.pressed:
		return
	if event.is_echo():
		return
	
	if event.keycode == KEY_ESCAPE:
		hide()


func display_window() -> void:
	if not visible:
		return
	
	SpriteExport.obj_data = get_owner().obj_data
