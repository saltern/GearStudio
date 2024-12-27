extends Window

@export var summon_button: Button
@export var import_file_dialog: FileDialog

var local_file_list: PackedStringArray
var object_name: String = ""

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	var base_name := sprite_edit.get_parent().name
	object_name = base_name.split("|")[-1].right(-1)
	
	title = tr("SPRITE_EDIT_IMPORT_TITLE").format({
		"name": object_name
	})
	
	summon_button.pressed.connect(display)
	close_requested.connect(hide)
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


func display() -> void:
	SpriteImport.obj_data = sprite_edit.obj_data
	SpriteImport.obj_name = object_name
	update(local_file_list)
	show()


func on_files_selected(files: PackedStringArray) -> void:
	local_file_list = files
	update(local_file_list)


func update(files: PackedStringArray) -> void:
	SpriteImport.select_files(files)
