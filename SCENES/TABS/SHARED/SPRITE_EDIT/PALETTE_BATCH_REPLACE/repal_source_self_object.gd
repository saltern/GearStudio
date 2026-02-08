extends OptionButton


func _ready() -> void:
	var session: Dictionary = SessionData.get_current_session()
	
	for key: int in session.data:
		if not session.data[key].has("name"):
			continue
		
		add_item(session.data[key].name, key)
