extends ConfirmationDialog


func _ready() -> void:
	confirmed.connect(save_confirmed)


func save_confirmed() -> void:
	print_debug("save_overwrite.gd::GlobalSignals.menu_save.emit()")
	GlobalSignals.menu_save.emit()
