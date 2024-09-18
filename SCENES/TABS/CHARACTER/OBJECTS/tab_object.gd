extends TabContainer

var object_edit_state: ObjectEditState


func _ready() -> void:
	object_edit_state = SessionData.object_state_get_s(name)
