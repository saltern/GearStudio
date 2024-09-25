extends Window

@export var display_button: Button

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	display_button.pressed.connect(show)
	close_requested.connect(hide)

	title = "Box display types for '%s'" % cell_edit.get_parent().name
