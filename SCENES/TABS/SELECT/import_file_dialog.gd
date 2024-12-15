extends FileDialog


@export var summon_button: Button

@onready var select_edit: SelectEdit = owner


func _ready() -> void:
	summon_button.pressed.connect(show)
	file_selected.connect(select_edit.import)
