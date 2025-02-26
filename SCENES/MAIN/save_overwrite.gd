extends ConfirmationDialog


func _ready() -> void:
	confirmed.connect(save_confirmed)


func save_confirmed() -> void:
	GlobalSignals.menu_save.emit()
