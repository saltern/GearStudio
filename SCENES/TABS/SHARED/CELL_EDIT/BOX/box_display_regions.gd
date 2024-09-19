extends CheckButton

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	toggled.connect(cell_edit.box_set_display_regions)
