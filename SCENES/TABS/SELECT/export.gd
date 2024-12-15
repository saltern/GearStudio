extends Button


@onready var select_edit: SelectEdit = owner


func _ready() -> void:
	pressed.connect(select_edit.export.bind("C:\\users\\alt_o\\desktop"))
