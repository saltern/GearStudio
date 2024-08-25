class_name SessionList extends Resource

var sessions: Dictionary = {}


func get_session(tab_id: int = 0) -> Dictionary:
	return sessions[tab_id]


func get_object_edit_state(
		tab_id: int = 0, object_name: String) -> ObjectEditState:
	
	
