extends ConfirmationDialog


func _ready() -> void:
	canceled.connect(hide)
