extends OptionButton

@onready var ref_handler: ReferenceHandler = owner.ref_handler


func _ready() -> void:
	ref_handler.ref_session_set.connect(update_objects)
	ref_handler.ref_session_cleared.connect(update_objects.bind({}))
	item_selected.connect(set_reference_data)
	
	update_objects({})
	
	Settings.language_changed.connect(on_language_changed)


func on_language_changed() -> void:
	for item in range(1, item_count):
		var entry_name: String = tr("REFERENCE_OBJECT_ENTRY").format({
			"index": item
		})
		set_item_text(item, entry_name)


func update_objects(session: Dictionary) -> void:
	clear()
	
	add_item("REFERENCE_OBJECT_NONE", -2)
	
	if not session.has("data"):
		return
	
	for object in session.data.size():
		if session.data[object].type == "unsupported":
			continue
		
		var entry_name: String = tr("REFERENCE_OBJECT_ENTRY").format({
			"index": object
		})
		add_item(entry_name, object)


func set_reference_data(index: int) -> void:
	var id: int = get_item_id(index)
	
	if id < 0:
		ref_handler.reference_clear_object()
		return
	
	ref_handler.reference_set_object(id)
