extends Window

@export var import_file_dialog: FileDialog

var local_file_list: PackedStringArray

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	title = "Import '%s' sprites..." % get_owner().get_parent().name

	close_requested.connect(hide)
	visibility_changed.connect(on_display)
	import_file_dialog.files_selected.connect(on_files_selected)


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


func on_display() -> void:
	if not visible:
		return
	
	SpriteImport.obj_data = sprite_edit.obj_data
	update(local_file_list)


func on_files_selected(files: PackedStringArray) -> void:
	local_file_list = files
	update(local_file_list)


func update(files: PackedStringArray) -> void:
	SpriteImport.select_files(files)
