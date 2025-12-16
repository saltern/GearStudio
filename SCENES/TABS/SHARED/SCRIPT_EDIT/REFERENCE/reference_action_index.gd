extends SteppingSpinBox

@onready var ref_handler: ReferenceHandler = owner.ref_handler


func _ready() -> void:
	min_value = -1
	on_ref_data_cleared()

	ref_handler.ref_data_set.connect(on_ref_data_set)
	ref_handler.ref_data_cleared.connect(on_ref_data_cleared)
	ref_handler.ref_session_cleared.connect(on_ref_data_cleared)
	value_changed.connect(update)


func on_ref_data_set(data: Dictionary) -> void:
	if not data.has("scripts"):
		on_ref_data_cleared()
		return
	
	max_value = data.scripts.actions.size() - 1
	editable = true


func on_ref_data_cleared() -> void:
	max_value = -1
	editable = false


func update(_new_value: float) -> void:
	ref_handler.reference_action_set(value)
