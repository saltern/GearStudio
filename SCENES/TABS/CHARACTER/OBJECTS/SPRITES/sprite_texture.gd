extends TextureRect


func _enter_tree() -> void:
	if get_owner().get_parent().name != "player":
		material = material.duplicate()
