extends CheckButton


func _ready() -> void:
	# Visibility control
	SpriteImport.placement_method_set.connect(on_placement_method_set)
	on_placement_method_set()
	
	# Toggling, updating
	get_parent().visibility_changed.connect(update)
	toggled.connect(update.unbind(1))


func on_placement_method_set() -> void:
	match SpriteImport.placement_method:
		SpriteImport.PlaceMode.REPLACE:
			show()
		_:
			hide()


func update() -> void:
	SpriteImport.place_by_filename = button_pressed
