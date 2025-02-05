extends FileDialog

@export var summon_button: Button


func _ready() -> void:
	file_selected.connect(on_file_selected)
	summon_button.pressed.connect(display)


func display() -> void:
	show()


func on_file_selected(path: String) -> void:
	print(path)
