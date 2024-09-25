extends Button

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	toggled.connect(on_toggle)


func on_toggle(enabled: bool) -> void:
	cell_edit.box_display_spawn = enabled
