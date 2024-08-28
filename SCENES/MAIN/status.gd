extends Label


func _ready() -> void:
	Status.status_updated.connect(update)


func update(string: String) -> void:
	text = string
	queue_redraw()
