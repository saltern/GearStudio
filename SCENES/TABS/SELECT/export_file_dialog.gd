extends FileDialog


@export var summon_button: Button

@onready var select_edit: SelectEdit = owner


func _ready() -> void:
	summon_button.pressed.connect(display)
	file_selected.connect(select_edit.export)
	file_selected.connect(register_path)


func display() -> void:
	if visible:
		return
	
	current_dir = FileMemory.select_export.get_base_dir()
	current_file = ""
	show()


func register_path(_path: String) -> void:
	FileMemory.select_export = current_path
