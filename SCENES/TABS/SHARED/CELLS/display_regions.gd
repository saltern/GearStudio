extends CheckButton


func _ready() -> void:
	toggled.connect(SessionData.box_set_display_regions)
