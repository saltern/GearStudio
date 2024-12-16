extends FileDialog


@export var summon_button: Button

@onready var select_edit: SelectEdit = owner


func _ready() -> void:
	summon_button.pressed.connect(display)
	file_selected.connect(select_edit.import)
	file_selected.connect(register_path)


func display() -> void:
	if visible:
		return
	
	current_path = FileMemory.select_import
	show()


func register_path(path: String) -> void:
	FileMemory.select_import = current_path
