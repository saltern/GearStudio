extends FileDialog


@export var summon_button: Button

@onready var select_edit: SelectEdit = owner


func _ready() -> void:
	summon_button.pressed.connect(display)
	file_selected.connect(select_edit.import)
	file_selected.connect(register_path.unbind(1))


func display() -> void:
	if visible:
		return
	
	current_path = FileMemory.select_import
	show()


func register_path() -> void:
	FileMemory.select_import = current_path
