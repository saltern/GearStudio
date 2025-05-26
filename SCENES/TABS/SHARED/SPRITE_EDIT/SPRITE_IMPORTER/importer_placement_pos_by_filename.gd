extends CheckButton


func _ready() -> void:
	SpriteImport.placement_method_set.connect(on_placement_method_set)
	on_placement_method_set()


func on_placement_method_set() -> void:
	match SpriteImport.placement_method:
		SpriteImport.PlaceMode.REPLACE:
			show()
		_:
			hide()
