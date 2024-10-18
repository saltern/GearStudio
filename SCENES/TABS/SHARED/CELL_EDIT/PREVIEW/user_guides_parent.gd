extends Control


func clear_guides() -> void:
	for child in get_children():
		child.queue_free()
