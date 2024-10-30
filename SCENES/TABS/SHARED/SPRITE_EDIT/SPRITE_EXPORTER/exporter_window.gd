extends Window

@export var summon_button: Button
@export var export_path_dialog: FileDialog

@onready var sprite_edit: SpriteEdit = owner


func _ready() -> void:
	title = "Export '%s' sprites..." % get_owner().get_parent().name
	summon_button.pressed.connect(display)
	close_requested.connect(hide)
	
	SpriteExport.hide_exporter_windows.connect(hide)


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


func display() -> void:
	SpriteExport.hide_exporter_windows.emit()
	SpriteExport.obj_data = sprite_edit.obj_data
	show()
