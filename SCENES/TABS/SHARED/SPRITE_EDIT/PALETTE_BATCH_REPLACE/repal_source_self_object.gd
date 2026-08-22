extends OptionButton

@onready var sprite_edit: SpriteEdit = owner


#func _ready() -> void:
	#var session: Session = SessionData.get_current_session()
	#
	#for key: int in session.data:
		#if not session.data[key].has("name"):
			#add_item("(Tab #%d)" % key, key)
		#else:
			#add_item(session.data[key].name, key)
