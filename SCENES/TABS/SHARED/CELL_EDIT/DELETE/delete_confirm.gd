extends ConfirmationDialog

@export var delete_from: SteppingSpinBox
@export var delete_to: SteppingSpinBox
@export var summon_button: Button
@export var cannot_delete: AcceptDialog

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	summon_button.pressed.connect(display)
	confirmed.connect(delete_cells)


func display() -> void:
	var delete_count: int = delete_to.value - delete_from.value + 1
	
	if delete_count >= cell_edit.cell_get_count():
		cannot_delete.show()
		return
	
	dialog_text = "Really delete %s cell(s)?" % delete_count
	show()


func delete_cells() -> void:
	cell_edit.cell_delete(delete_from.value, delete_to.value)
