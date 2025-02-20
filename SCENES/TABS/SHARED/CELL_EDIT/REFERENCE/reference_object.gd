extends OptionButton

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	cell_edit.ref_session_set.connect(update_objects)
	cell_edit.ref_data_cleared.connect(update_objects.bind({}))
	item_selected.connect(set_reference_data)


func update_objects(session: Dictionary) -> void:
	clear()
	
	if not session.has("data"):
		add_item("Select a reference file first.")
		set_item_disabled(0, true)
		return
	
	print("Number of objects: %s." % session["data"].size())
	
	for object in session["data"].size():
		add_item("Object #%s" % object)


func set_reference_data(id: int) -> void:
	cell_edit.reference_set_object(id)
