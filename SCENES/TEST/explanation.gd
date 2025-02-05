extends Label

@onready var SI := ScriptInstructions


func display_explanation(instruction_id: int = -1) -> void:
	text = get_explanation(instruction_id)


func get_explanation(instruction_id: int = -1) -> String:
	match instruction_id:
		0:
			return "Displays a cell for up to 255 frames."
		
		69:
			return "Applies an effect to the sprite."
		
		255:
			return "Marks the action as finished."

	return ""
