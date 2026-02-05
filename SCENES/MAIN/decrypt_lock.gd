extends Window


func _ready() -> void:
	hide()
	GlobalSignals.decryption_start.connect(show)
	GlobalSignals.decryption_end.connect(hide)
