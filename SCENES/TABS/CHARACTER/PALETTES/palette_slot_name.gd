extends Label


func _ready() -> void:
	SessionData.palette_changed.connect(on_palette_changed)
	text = get_palette_name(0)


func on_palette_changed(for_session: int, index: int) -> void:
	if for_session != owner.session_id:
		return
	
	text = get_palette_name(index)


func get_palette_name(index: int) -> String:
	# Special cases
	# 14: Gold, 19: Shadow, 20: Slash D, 21: Reload D
	
	match index:
		14: return "Gold"
		19: return "Shadow"
		20: return "Slash D"
		21: return "Reload D"
	
	var pal_set: String = ""
	var pal_btn: String = ""
	
	var set_index: int = index / 5
	var btn_index: int = index % 5
	
	match set_index:
		0: pal_set = "Normal "
		1: pal_set = "EX "
		2: pal_set = "Slash "
		3: pal_set = "Reload "
	
	match btn_index:
		0: pal_btn = "P"
		1: pal_btn = "K"
		2: pal_btn = "S"
		3: pal_btn = "H"
		4: pal_btn = "D"
	
	return pal_set + pal_btn
