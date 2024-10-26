extends Button

@export var range_start: SpinBox
@export var range_end: SpinBox

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	#pressed.connect(delete_cells)
	
	range_start.value_changed.connect(check_enable.unbind(1))
	range_end.value_changed.connect(check_enable.unbind(1))


#func delete_cells() -> void:
	#if is_deleting_all_cells():
		#check_enable()
		#return
		#
	#cell_edit.cell_delete(range_start.value, range_end.value)


func check_enable() -> void:
	disabled = is_deleting_all_cells()


func is_deleting_all_cells() -> bool:
	var delete_count: int = 1 + range_end.value - range_start.value
	return delete_count >= cell_edit.cell_get_count()
